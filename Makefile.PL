#! /usr/bin/perl

&check_kit;

print STDERR <<EOT;
The behaviour of this script varies according to which directories
you can write to; therefore you should run it as the same user (eg
root) that will execute the 'make install' step.

It will end up installing the files Tea.pm and tea, and possibly
their manual pages.

Use the arrow keys (or h,j,k,l) and <Return> to make your choices.

EOT

my $version = '1.30';
my $bindir  = &bindir;
my $libdir  = &libdir . '/Crypt';
my $mandir  = &mandir;
my $comment = &comment;

require './which.pl'; my $perlbin = &which('perl');
if (! $perlbin) { die "Sorry, no perl in PATH\n"; }

# ----------  first build the 'Makefile' ...

if (! open (F, '> Makefile')) { die "Sorry, can't open Makefile: $!\n"; }
if ($libdir)  { print F "LIBDIR = $libdir\n"; }
if ($bindir)  { print F "BINDIR = $bindir\n"; }
if ($mandir)  { print F "MANDIR = $mandir\n"; }

print F <<'EOT';

local : Tea.pm.local tea.local

EOT
if ($mandir) { print F <<'EOT';
install : local ${LIBDIR}/Tea.pm ${BINDIR}/tea \
${MANDIR}/tea.1
EOT
} else { print F <<'EOT';
install : local ${LIBDIR}/Tea.pm ${BINDIR}/tea
EOT
}

print F <<'EOT';

Tea.pm.local : localise Tea.pm
	./localise Tea.pm > $@
tea.local : localise tea
	./localise tea > $@

${LIBDIR}/Tea.pm : Tea.pm.local
	perl -c Tea.pm.local
	test -d ${LIBDIR} || mkdir ${LIBDIR}
	chmod 755 ${LIBDIR}
	cp Tea.pm.local $@
	chmod 644 $@
${BINDIR}/tea : tea.local
	perl -c tea.local
	cp tea.local $@
	chmod 755 $@
EOT

if ($mandir) { print F <<'EOT'; }
${MANDIR}/tea.1 : tea.local
	pod2man tea.local > $@
	chmod 644 $@
EOT

print F <<EOT;
test : install
	lynx http://localhost${url}/htui,htauth_test.cgi
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

print "\nNow try 'make' then 'make install' and then 'make test' . . .\n";
exit 0;

# --------------------- infrastructure ---------------------

sub bindir {
	require './choose.pl';
	my (@tried, @writeable);
	foreach $dir (split /:/,$ENV{PATH}) {
		next if ($dir =~ /sbin$|\/root/);
		next if ($dir eq '.');
		push @tried, $dir;
		if (-w $dir) { push @writeable, $dir; }
	}
	if (! @writeable) { print STDERR <<EOT, "   ", join ("\n   ", @tried), "\n" ;
Sorry, can't write to any directories in your PATH; tried
EOT
		exit 1;
	} else {
		$bindir = &choose("Where should the executables be installed ?",
			@writeable, 'Somewhere Else');
		if ($bindir eq 'Somewhere Else') {
			require './ask.pl'; $bindir = &ask('in which directory, then ?');
			if (! $bindir) { die "not installing, nowhere to install\n"; }
			if (! -d $bindir) { die "Sorry, $bindir is not a directory.\n"; }
			if (! -w $bindir) { die "Sorry, $bindir is not writeable.\n"; }
		}
		if (! $bindir) { die "Sorry, nowhere to install the executables\n"; }
	}
	$bindir =~ s/\/$//;
	return $bindir;
}

sub libdir {
	require './choose.pl';
	my (@libdirs, @tried, @writeable, $libdir);
	@libdirs = grep (!/^\.$/, @INC);
	if ($cgidir) { unshift @libdirs, $cgidir; }
	foreach $dir (@libdirs) {
		next if ($dir eq '.');
		push @tried, $dir;
		if (-w $dir) { push @writeable, $dir; }
	}
	if (! @writeable) {
		require './ask.pl';
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
			require './ask.pl'; $libdir = &ask('in which directory, then ?');
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
	require './choose.pl';
	my (@tried, @writeable, $mandir);
	foreach $dir (split(/:/, $ENV{MANPATH})) {
		$dir =~ s/$/\/man1/;
		push @tried, $dir;
		if (-w $dir) { push @writeable, $dir; }
	}
	if (! @writeable) { print STDERR <<EOT, "   ", join ("\n   ", @tried), "\n" ;

Sorry, can't write to any directories in your MANPATH; tried
EOT
	}
	$mandir = &choose(
		"Where should the manual pages be installed ?",
		@writeable, 'Somewhere Else', 'Do Not Install Manual Pages');
	if ($mandir eq 'Somewhere Else') {
		require './ask.pl'; $mandir = &ask('in which directory, then ?');
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
	require 'timestamp.pl'; my $datestamp = &datestamp;
	return "made $datestamp by $user in $build_dir";
}

sub check_kit {
	print STDERR "Checking your kit ... ";

	my %file_sizes = (
		'Makefile.PL', 6518,
		'Tea.pm', 27017,
		'tea', 1821,
		'choose.pl', 5891,
		'timestamp.pl', 2142,
		'vt100.pl', 5925,
		'which.pl', 1316,
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
