#! /usr/bin/perl
require './Clui'; import Term::Clui;

&check_kit;

print STDERR <<EOT;
The behaviour of this script varies according to which directories
you can write to; therefore you should run it as the same user (eg
root) that will execute the 'make install' step.

It will end up installing the files Tea.pm and tea, and possibly
their manual pages.

Use the arrow keys (or h,j,k,l) and <Return> to make your choices.

EOT

my $version = '1.35';
my $bindir  = &bindir;
my $libdir  = &libdir . '/Crypt';
my $mandir  = &mandir;
my $comment = &comment;
my $perlbin = &which('perl');
if (! $perlbin) { die "Sorry, no perl in PATH\n"; }

# ----------  first build the 'Makefile' ...

if (! open (F, '> Makefile')) { die "Sorry, can't open Makefile: $!\n"; }
if ($libdir)  { print F "LIBDIR = $libdir\n"; }
if ($bindir)  { print F "BINDIR = $bindir\n"; }
if ($mandir)  { print F "MANDIR = $mandir\n"; }

print F <<'EOT';

local : Tea.local tea.local

EOT
if ($bindir && $mandir) { print F <<'EOT';
install : local ${LIBDIR}/Tea.pm ${BINDIR}/tea \
${MANDIR}/man3/Crypt_Tea.3 ${MANDIR}/man1/tea.1
EOT
} elsif ($bindir) { print F <<'EOT';
install : local ${LIBDIR}/Tea.pm ${BINDIR}/tea
EOT
} elsif ($mandir) { print F <<'EOT';
install : local ${LIBDIR}/Tea.pm ${MANDIR}/man3/Crypt_Tea.3
EOT
} else { print F <<'EOT';
install : local ${LIBDIR}/Tea.pm
EOT
}

print F <<'EOT';

Tea.local : localise Tea.pm
	./localise Tea.pm > $@

${LIBDIR}/Tea.pm : Tea.local
	perl -c Tea.local
	test -d ${LIBDIR} || mkdir ${LIBDIR}
	chmod 755 ${LIBDIR}
	cp Tea.local $@
	chmod 644 $@

EOT
if ($bindir) { print F <<'EOT'; }
tea.local : localise tea
	./localise tea > $@

${BINDIR}/tea : tea
	perl -c tea
	cp tea $@
	chmod 755 $@

EOT

if ($mandir) { print F <<'EOT'; }
${MANDIR}/man3/Crypt_Tea.3 : Tea.local
	pod2man Tea.local > $@
	chmod 644 $@
	cp $@ ${MANDIR}/man3/Crypt::Tea.3
	chmod 644 ${MANDIR}/man3/Crypt::Tea.3

EOT

if ($bindir && $mandir) { print F <<'EOT'; }
${MANDIR}/man1/tea.1 : tea
	pod2man tea > $@
	chmod 644 $@

EOT


print F <<EOT;
test :
	perl test_script
EOT

close F;

# ---------  now build the 'localise' and 'modulise' scripts ...

if (! open (F, '> localise')) { die "Sorry, can't open localise: $!\n"; }
print F "#! $perlbin\nwhile (<>) {\n";
if ($comment) { $comment =~ s#/#\\/#g; print F "\ts/#COMMENT#/$comment/;\n"; }
$perlbin =~ s#/#\\/#g; print F "\ts/#PERLBIN#/$perlbin/;\n";
$libdir  =~ s#/#\\/#g; print F "\ts/#LIBDIR#/$libdir/;\n";
$bindir  =~ s#/#\\/#g; print F "\ts/#BINDIR#/$bindir/;\n";
if ($version) { print F "\ts/#VERSION#/$version/;\n"; }
print F "\tprint;\n}\n";
close F;
chmod 0744, 'localise';

print "\nNow try 'make' then 'make test' and then 'make install' . . .\n";
exit 0;

# --------------------- infrastructure ---------------------

sub bindir {
	my (%tried, %writeable);
	foreach $dir ('/usr/local/bin',split /:/,$ENV{PATH}) {
		next if ($dir =~ /sbin$|\/root/);
		next if ($dir eq '.');
		$tried{$dir} = 1;
		if (-w $dir) { $writeable{$dir} = 1; }
	}
	if (! %writeable) {
		print STDERR <<EOT, "   ", join ("\n   ", keys %tried), "\n" ;
Sorry, can't write to any directories in your PATH; tried
EOT
		exit 1;
	} else {
		$bindir = &choose("Where should the executable be installed ?",
			keys %writeable, 'Somewhere Else', 'Do not install the executable');
		if ($bindir eq 'Somewhere Else') {
			$bindir = &ask('in which directory, then ?');
			# if (! $bindir) { die "not installing, nowhere to install\n"; }
			if (! $bindir) { warn "not installing the executable\n"; return ''; }
			if (! -d $bindir) { die "Sorry, $bindir is not a directory.\n"; }
			if (! -w $bindir) { die "Sorry, $bindir is not writeable.\n"; }
		} elsif ($bindir eq 'Do not install the executable') {
			return '';
		}
		# if (! $bindir) { die "Sorry, nowhere to install the executables\n"; }
	}
	$bindir =~ s/\/$//;
	return $bindir;
}

sub libdir {
	my (@libdirs, @tried, @writeable, $libdir);
	@libdirs = grep (!/^\.$/, @INC);
	if ($cgidir) { unshift @libdirs, $cgidir; }
	foreach $dir (@libdirs) {
		next if ($dir eq '.');
		push @tried, $dir;
		if (-w $dir) { push @writeable, $dir; }
	}
	if (! @writeable) {
		
		print STDERR <<'EOT';

Where should the Perl module be installed ? You don't have write permission
to any of the directories in your @INC path; if you wish to install in some
EOT
		$libdir = &ask('other directory, enter it :');
		if (! $libdir) { die "not installing, nowhere to install module\n"; }
		if (! -d $libdir) { die "Sorry, $libdir is not a directory.\n"; }
		if (! -w $libdir) { die "Sorry, $libdir is not writeable.\n"; }
	} else {
		$libdir = &choose("Where should the Perl module be installed ?",
			@writeable, 'Somewhere Else');
		if ($libdir eq 'Somewhere Else') {
			$libdir = &ask('in which directory, then ?');
			if (! $libdir) { die "not installing, nowhere to install\n"; }
			if (! -d $libdir) { die "Sorry, $libdir is not a directory.\n"; }
			if (! -w $libdir) { die "Sorry, $libdir is not writeable.\n"; }
		}
		if (! $libdir) { die "Sorry, nowhere to install the Perl libraries\n"; }
	}
	$libdir =~ s/\/$//;
	return $libdir;
}

sub mandir {
	my (@tried, @writeable, $mandir);
	foreach $dir (split(/:/, $ENV{MANPATH})) {
		push @tried, $dir;
		if (-w "$dir/man1") { push @writeable, $dir; }
	}
	if (! @writeable) { print STDERR <<EOT, "   ", join ("\n   ", @tried), "\n" ;

Sorry, can't write to any directories in your MANPATH; tried
EOT
	}
	$mandir = &choose(
		"Where should the manual pages be installed ?",
		@writeable, 'Somewhere Else', 'Do Not Install Manual Pages');
	if ($mandir eq 'Somewhere Else') {
		$mandir = &ask('in which directory, then ?');
		if (! $mandir) { die "not installing, nowhere to install\n"; }
		if (! -d $mandir) { die "Sorry, $mandir is not a directory.\n"; }
		if (! -w $mandir) { die "Sorry, $mandir is not writeable.\n"; }
	} elsif ($mandir eq 'Do Not Install Manual Pages') {
		return '';
	} elsif (! $mandir) {
		die "Sorry, nowhere to install the manual pages\n";
	}
	$mandir =~ s/\/$//;
	return $mandir;
}

sub comment {
	my $user = (getpwuid($>))[$[];
	my $build_dir = `pwd`; $build_dir =~ s/\s+$//;
	my $datestamp = &datestamp;
	return "made $datestamp by $user in $build_dir";
}
sub which { my $file = $_[$[];   # looks for executables, Perl libraries
	return '' unless $file;
	my $slash = (-f "c:\autoexec.bat") ? '\\' : '/';
	my $absfile;
	if ($file =~ /\.p[lm]$/) {   # perl library or module ?
		foreach $dir (@INC) {
			$absfile = "$dir$slash$file";	return $absfile if -r $absfile;
		}
	} else {	# executable ?
		foreach $dir (split (":", $ENV{PATH})) {
			$absfile = "$dir$slash$file";	return $absfile if -x $absfile;
		}
	}
}
sub datestamp { # returns current date in "19940314" format
	local ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime;
	sprintf ("%4.4d%2.2d%2.2d", $year+1900, $mon+1, $mday);
}

sub check_kit {
	print STDERR "Checking your kit ... ";

	my %file_sizes = (
		'README', 1612,
		'Changes', 363,
		'MANIFEST', 82,
		'Makefile.PL', 7609,
		'Tea.pm', 25625,
		'tea', 2997,
		'Clui', 29518,
		'test_script', 3417,
		'test.html', 17781,
	);

	my $problem_found = 0;
	foreach $file (keys %file_sizes) {
		if (! -f $file) {
			if (! $problem_found) { $problem_found = 1; print STDERR "\n"; }
			print STDERR "   missing: $file\n"
		} elsif (-s $file != $file_sizes{$file}) {
			if (! $problem_found) { $problem_found = 1; print STDERR "\n"; }
			my $is = -s $file;
			my $should = $file_sizes{$file};
			print STDERR "   wrong size: $file is $is, should be $should bytes\n"
		}
	}
	if ($problem_found) { exit 1;
	} else { print STDERR "Looks good.\n\n"; return 1;
	}
}
