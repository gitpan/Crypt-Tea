# Term::Clui.pm
#########################################################################
#        This Perl module is Copyright (c) 2002, Peter J Billam         #
#               c/o P J B Computing, www.pjb.com.au                     #
#                                                                       #
#     This module is free software; you can redistribute it and/or      #
#            modify it under the same terms as Perl itself.             #
#########################################################################
# to be done - &ask should accept a default as an optional 2nd arg

package Term::Clui;
$VERSION = '1.10';
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(ask_password ask confirm choose edit view);
@EXPORT_OK = qw(beep tiview);

# ------------------------ vt100 stuff -------------------------

$A_NORMAL    =  0;
$A_BOLD      =  1;
$A_UNDERLINE =  2;
$A_REVERSE   =  4;
$KEY_UP    = oct(403);
$KEY_LEFT  = oct(404);
$KEY_RIGHT = oct(405);
$KEY_DOWN  = oct(402);
$KEY_ENTER = "\r";
$KEY_PPAGE = oct(523);
$KEY_NPAGE = oct(522);
$KEY_BTAB  = oct(541);

$bsd = (-f "/kernel" || -f "/vmunix" || -f "/386bsd");

sub addch  { print TTY @_; }
sub addstr { print TTY @_; }
sub attrset { my $attr = $_[$[];
	if (! $attr) {
		print TTY "\033[0m";
	} else {
		if ($attr & $A_BOLD)      { print TTY "\033[1m" };
		if ($attr & $A_REVERSE)   { print TTY "\033[7m" };
		if ($attr & $A_UNDERLINE) { print TTY "\033[4m" };
	}
}
sub beep     { print TTY "\07"; }
sub clear    { print TTY "\033[H\033[J"; }
sub clrtoeol { print TTY "\033[K"; }
sub endwin {
	print TTY "\033[0m";
	require 'flush.pl'; &flush (TTY);
	close TTY; close TTYIN;
	if ($^O eq 'FreeBSD') {
		system("stty $stty </dev/tty") if $stty;
	} else {
		system("stty $stty </dev/tty >/dev/tty") if $stty;
	}
}
sub getch {
	local ($c);
	$c = getc(TTYIN);
	if ($c eq "\033") {
		$c = getc(TTYIN);
		if ($c eq "A") { return($KEY_UP); }
		if ($c eq "B") { return($KEY_DOWN); }
		if ($c eq "C") { return($KEY_RIGHT); }
		if ($c eq "D") { return($KEY_LEFT); }
		if ($c eq "5") { getc(TTYIN); return($KEY_PPAGE); }
		if ($c eq "6") { getc(TTYIN); return($KEY_NPAGE); }
		if ($c eq "Z") { return($KEY_BTAB); }
		if ($c eq "[") {
			$c = getc(TTYIN);
			if ($c eq "A") { return($KEY_UP); }
			if ($c eq "B") { return($KEY_DOWN); }
			if ($c eq "C") { return($KEY_RIGHT); }
			if ($c eq "D") { return($KEY_LEFT); }
			if ($c eq "5") { getc(TTYIN); return($KEY_PPAGE); }
			if ($c eq "6") { getc(TTYIN); return($KEY_NPAGE); }
			if ($c eq "Z") { return($KEY_BTAB); }
			return($c);
		}
		return($c);
	} elsif ($c == oct(0217)) {
		$c = getc(TTYIN);
		if ($c eq "A") { return($KEY_UP); }
		if ($c eq "B") { return($KEY_DOWN); }
		if ($c eq "C") { return($KEY_RIGHT); }
		if ($c eq "D") { return($KEY_LEFT); }
		return($c);
	} elsif ($c == oct(0233)) {
		$c = getc(TTYIN);
		if ($c eq "A") { return($KEY_UP); }
		if ($c eq "B") { return($KEY_DOWN); }
		if ($c eq "C") { return($KEY_RIGHT); }
		if ($c eq "D") { return($KEY_LEFT); }
		if ($c eq "5") { getc(TTYIN); return($KEY_PPAGE); }
		if ($c eq "6") { getc(TTYIN); return($KEY_NPAGE); }
		if ($c eq "Z") { return($KEY_BTAB); }
		return($c);
	} else {
		return($c);
	}
}
sub puts  { print TTY @_; }
sub up    { my $i; for ($i=0; $i<$_[$[]; $i++) { print TTY "\033[A"; } }
sub down  { my $i; for ($i=0; $i<$_[$[]; $i++) { print TTY "\033[B"; } }
sub right { my $i; for ($i=0; $i<$_[$[]; $i++) { print TTY "\033[C"; } }
sub left  { my $i; for ($i=0; $i<$_[$[]; $i++) { print TTY "\033[D"; } }
sub initscr {
	open(TTY, ">/dev/tty")  || (warn "Can't write /dev/tty: $!\n", return 0);
	$stty = `stty -g`; chop $stty;
	open(TTYIN, "</dev/tty") || (warn "Can't read /dev/tty: $!\n", return 0);

	if ($^O eq 'FreeBSD') {
		system("stty -echo -icrnl raw </dev/tty");
	} else {
		system("stty -echo -icrnl raw </dev/tty >/dev/tty");
	}
	# system("stty -echo -icrnl raw </dev/tty");  # various old tries ...
	# system("stty -echo -icrnl raw");
	# if ($bsd) { system "stty cbreak </dev/tty >/dev/tty 2>&1";
	# } else { system "stty", '-icanon'; system "stty", 'eol', "\001";
	# }
	require 'flush.pl'; &flush (TTY);
	select((select(TTY), $| = 1)[$[]);
}
sub move { local ($ix,$iy) = @_; printf TTY "\033[%d;%dH",$iy+1,$ix+1; }
sub beep { print TTY "\07"; }

# ----------------------- size handling ----------------------

eval 'require "Term/Size.pm"';
if ($@) { $must_use_tput = 1; }

sub cols_and_rows {
	my ($maxcols, $maxrows);
	if ($must_use_tput) {
		$maxcols = `tput cols`;
		if ($^O eq 'linux') { $maxrows = (`tput lines` + 0);
		} else { $maxrows = (`tput rows` + 0);
		}
	} else {
		($maxcols, $maxrows) = &Term::Size::chars(*STDERR);
	}
	$maxcols = $maxcols || 80; $maxcols--;
	$maxrows = $maxrows || 24;
	return ($maxcols, $maxrows);
}
$SIG{'WINCH'} = sub { $size_changed = 1; };

# ------------------------ ask stuff -------------------------

sub ask_password { local ($question) = @_;  # no echo - use for passwords
	local ($silent) = 'yes';	&ask ($question);
}
sub ask { local ($question) = $_[$[];	# returns a one-line text-entry answer
	return '' unless $question;
	&initscr(); my $nol = &display_question($question);

   my $i = 0; my $n = 0; my @s = (); # cursor position, length, string

	for (;;) {
		$c = &getch();
		if ($c eq "\r") { &erase_next_lines($nol); last; }
		if ($size_changed) {
			&erase_next_lines($nol); &up(1); $nol = &display_question($question);
		}
		if ($c == $KEY_LEFT && $i > 0) { $i--; &addch ("\010");
		} elsif ($c == $KEY_RIGHT) {
			if ($i < $n) { &addch ($silent ? "x" : $s[$i]); $i++; }
		} elsif (($c eq "\cH") || ($c eq "\c?")) {
			if ($i > 0) {
			 	$n--; $i--;
			 	splice(@s, $i, 1);
			  	&addch ("\e[D");
			  	foreach $j ($i .. $n) { print "$s[$j]"; }
			  	&clrtoeol(); print "\cH" x ($n - $i);
			}
		} elsif ($c eq "\cL") {  # redraw ...
		} elsif ($c !~ /[\000-\031]/) {
			splice(@s, $i, 0, $c);
			$n++; $i++; &addch($silent ? "x" : $c);
			foreach $j ($i .. $n) { print "$s[$j]"; }
			&clrtoeol();  &left($n-$i);
		}
	}
	&endwin(); $silent = ''; return join("", @s);
}

# ----------------------- choose stuff -------------------------

sub choose {  local ($question, @list) = @_;
	# If called in array context, should probably allow multiple choice,
   # but this would be incompatible with the Tk widgets that would be
   # implementing &choose in a GUI environment ...

	return unless @list;
	grep (($_ =~ s/\n$//) && 0, @list);	# chop final \n if any

	local ($irow, %irow, $icol, %icol, $icell);
	local ($home) = $ENV{'HOME'} || $ENV{'LOGDIR'} || (getpwuid($<))[7];
	mkdir ("$home/db", 0750);

	$question =~ s/^[\n\r]+//;   # strip initial newline(s)
	$question =~ s/[\n\r]+$//;   # strip final newline(s)
	my ($firstline,$otherlines) = split ("\n", $question, 2);

	local ($choice);
	if ($firstline && dbmopen (%CHOICES, "$home/db/choices", 0600)) {
		$choice = $CHOICES{$firstline}; dbmclose %CHOICES;
	}

	($maxcols, $maxrows) = &cols_and_rows();
	&layout();
	if ($nrows > $maxrows) { # if too many for one screen, use complete.pl
		# but should ask for clue, grep the list, and offer choice when it fits
		# and should take account of multiline questions ...
		# Also: should re-enter this bit each time &layout is re-called ...
		require 'complete.pl';
		return &Complete("$firstline (TAB to complete, ^D to list) ", @list);
	}

	&initscr ();
	if ($firstline) { &puts("$firstline\r\n"); }
	$icol = 0; $irow = 1;
	&wr_screen(); &wr_cell($this_cell);
	for (;;) {
		last unless $c = &getch();
		if ($size_changed) {
			($maxcols, $maxrows) = &cols_and_rows(); $size_changed = 0;
			&erase_next_lines($nrows);
			&layout(); &wr_screen(); &wr_cell($this_cell);
		}
		if ($c eq "q" || $c eq "\cD") {
			for ($ir=0; $ir<=$nrows; $ir++) { &goto(0,$ir); &clrtoeol (); }
			&goto (0,0); &endwin (); return wantarray ? () : undef;
		} elsif ((($c eq " ") || ($c eq "\t")) && ($this_cell < $#list)) {
			$this_cell++; &wr_cell($this_cell-1); &wr_cell($this_cell); 
		} elsif ((($c eq "l") || ($c eq $KEY_RIGHT)) && ($this_cell < $#list)
			&& ($irow[$this_cell] == $irow[$this_cell+1])) {
			$this_cell++; &wr_cell($this_cell-1); &wr_cell($this_cell); 
		} elsif ((($c eq "\cH") || ($c eq $KEY_BTAB)) && ($this_cell > $[)) {
			$this_cell--; &wr_cell($this_cell+1); &wr_cell($this_cell); 
		} elsif ((($c eq "h") || ($c eq $KEY_LEFT)) && ($this_cell > $[)
			&& ($irow[$this_cell] == $irow[$this_cell-1])) {
			$this_cell--; &wr_cell($this_cell+1); &wr_cell($this_cell); 
		} elsif ((($c eq "j") || ($c eq $KEY_DOWN)) && ($irow < $nrows)) {
			$mid_col = $icol[$this_cell] + 0.5 * $l[$this_cell];
			$left_of_target = 1000;
			for ($inew=$this_cell+1; $inew < $#list; $inew++) {
				last if $icol[$inew] < $mid_col;	# skip rest of row
			}
			for (; $inew < $#list; $inew++) {
				$new_mid_col = $icol[$inew] + 0.5 * $l[$inew];
				last if $new_mid_col > $mid_col;		 # we're past it
				last if $icol[$inew+1] < $icol[$inew]; # we're at EOL
				$left_of_target = $mid_col - $new_mid_col;
			}
			if (($new_mid_col - $mid_col) > $left_of_target) { $inew--; }
			$iold = $this_cell; $this_cell = $inew;
			&wr_cell($iold); &wr_cell($this_cell);
		} elsif ((($c eq "k") || ($c eq $KEY_UP)) && ($irow > 1)) {
			$mid_col = $icol[$this_cell] + 0.5 * $l[$this_cell];
			$right_of_target = 1000;
			for ($inew=$this_cell-1; $inew > 0; $inew--) {
				last if $irow[$inew] < $irow[$this_cell];	# skip rest of row
			}
			for (; $inew > 0; $inew--) {
				last unless $icol[$inew];
				$new_mid_col = $icol[$inew] + 0.5 * $l[$inew];
				last if $new_mid_col < $mid_col;		 # we're past it
				$right_of_target = $new_mid_col - $mid_col;
			}
			if (($mid_col - $new_mid_col) > $right_of_target) { $inew++; }
			$iold = $this_cell; $this_cell = $inew;
			&wr_cell($iold); &wr_cell($this_cell);
		} elsif ($c eq "\cL") {
			if ($size_changed) {
				($maxcols, $maxrows) = &cols_and_rows(); $size_changed = 0;
				for ($ir=1; $ir<=$nrows; $ir++) { &goto(0,$ir); &clrtoeol (); }
				&goto (0,1); &layout();
			}
			&wr_screen(); &wr_cell($this_cell);
		} elsif ($c eq "\r") {
			for ($ir=1; $ir<=$nrows; $ir++) { &goto(0,$ir); &clrtoeol (); }
			&goto ((length $firstline)+2,0);
			&addstr($list[$this_cell] . "\n\r");
			&clrtoeol (); &endwin ();
			if ($firstline && dbmopen (%CHOICES, "$home/db/choices", 0600)) {
				$CHOICES{$firstline} = $list[$this_cell];
				dbmclose %CHOICES;
			}
			return wantarray ? ($list[$this_cell]) : $list[$this_cell];
		}
	}
	&endwin ();
}
sub layout {
	my $irow = 1; my $icol = 0; # my $this_cell = $[;
	for ($icell=$[; $icell <= $#list; $icell++) {
		$l[$icell] = length ($list[$icell]) + 2;
		if (($icol + $l[$icell]) >= $maxcols ) { $irow++; $icol = 0; }
		$irow[$icell] = $irow; $icol[$icell] = $icol;
		$icol += $l[$icell];
		if ($list[$icell] eq $choice) { $this_cell = $icell; }
	}
	$nrows = $irow;
}
sub wr_screen {
	&addstr ("\r");	$icol = 0;
	for ($icell= $[; $icell <=$#list; $icell++) { &wr_cell ($icell); }
}
sub wr_cell { local ($icell) = @_;
	&goto ($icol[$icell], $irow[$icell]);
	if ($marked[$icell]) { &attrset($A_BOLD); }
	if ($icell == $this_cell) { &attrset($A_REVERSE); }
	local ($no_tabs) = $list[$icell];
	$no_tabs =~ s/\t/ /;
	$no_tabs =~ s/^(.{1,77}).*/\1/;
	&addstr(" $no_tabs ");
	if ($marked[$icell] || $icell == $this_cell) { &attrset($A_NORMAL); }
	$icol += length ($no_tabs) + 2;
	# sleep(1);
}
sub goto { local ($newcol, $newrow) = @_;
	if ($newcol > $icol)      { &right($newcol-$icol);
	} elsif ($newcol < $icol) { &left ($icol-$newcol);
	}
	$icol = $newcol;
	if ($newrow > $irow)      { &addstr ("\n" x ($newrow-$irow));
	} elsif ($newrow < $irow) { &up  ($irow-$newrow);
	}
	$irow = $newrow;
}

# ----------------------- confirm stuff -------------------------

sub confirm { my $question = shift;  # asks user Yes|No, returns 1|0
	return(0) unless $question;  return(0) unless -t STDERR;
	&initscr(); my $nol = &display_question($question); &puts (" (y/n) ");
	while () { $response=&getch();  last if ($response=~/[yYnN]/);  &beep(); }
	&left(6); &clrtoeol(); 
	if ($response=~/^[yY]/) { &puts("Yes"); } else { &puts("No"); }
	&erase_next_lines($nol); &endwin();
	if ($response =~ /^[yY]/) { return 1; } else { return 0 ; }
}

# ----------------------- edit stuff -------------------------

sub edit {	local ($title, $text) = @_;
	$argc = $#_ - $[ +1;
	my ($dirname, $basename, $rcsdir, $rcsfile, $rcs_ok);
	
	if ($argc == 0) {	# start editor session with no preloaded file
		system $ENV{EDITOR} || "vi"; # should also look in ~/db/choices.db
	} elsif ($argc == 2) {
		# must create tmp file with title embedded in name
		$tmpdir = '/tmp';
		($safename = $title) =~ s/[\W_]+/_/g;
		$file = "$tmpdir/$safename.$$";
		if (!open (F,"> $file")) {&sorry("can't open $file: $!\n");return '';}
		print F $text; close F;
		$editor = $ENV{EDITOR} || "vi"; # should also look in ~/db/choices.db
		system "$editor $file";
		if (!open (F,"< $file")) {&sorry ("can't open $file: $!\n");return 0;}
		undef $/; $text = <F>; $/ = "\n";
		close F; unlink $file; return $text;
	} elsif ($argc == 1) {	# its a file, we will try RCS ...
		local ($file) = $title;

		# weed out no-go situations
		if (-d $file)  { &sorry ("$file is already a directory\n"); return 0; }
		if (-B _ && -s _)  { &sorry("$file is not a text file\n");  return 0; }
		if (-T _ && !-w _) { &view ($file); return 1; }
	
		# it's a writeable text file, so work out the locations
		if ($file =~ /\//) {
			($dirname, $basename) = $file =~ /^(.*)\/([^\/]+)$/;
			$rcsdir  = "$dirname/RCS";
			$rcsfile = "$rcsdir/$basename,v";
		} else {
			$basename = $file;
			$rcsdir  = "RCS";
			$rcsfile = "$rcsdir/$basename,v";
		}
		$rcslog = "$rcsdir/log";
	
		# we no longer create the RCS directory if it doesn't exist,
		# so `mkdir RCS' to enable rcs in a directory ...
		$rcs_ok = 1;	if (!-d $rcsdir) { $rcs_ok = 0; }
		if (-d _ && ! -w _) { $rcs_ok = 0;	warn "can't write in $rcsdir\n"; }
	
		# if the file doesn't exist, but the RCS does, then check it out
		if ($rcs_ok && -f $rcsfile && !-f $file) {system "co -l $file $rcsfile";}

		my $starttime = time;
		$editor = $ENV{EDITOR} || "vi"; # should also look in ~/db/choices.db
		system "$editor $file";
		my $elapsedtime = time - $starttime;
		# could be output or logged, for worktime accounting
	
		if ($rcs_ok && -T $file) {	 # check it in
			if (!-f $rcsfile) {
				my $msg = &ask ("$file is new. Please describe it:");
				my $quotedmsg = $msg;  $quotedmsg =~ s/'/'"'"'/g;
				if ($msg) {
					system "rcs -i -U -t-'$quotedmsg' $file $rcsfile";
					&logit ($basename, $msg);
				}
			} else {
				my $msg = &ask ("What changes have you made to $file ?");
				my $quotedmsg = $msg;  $quotedmsg =~ s/'/'"'"'/g;
				if ($msg) {
					system "ci -q -l -m'$quotedmsg' $file $rcsfile";
					&logit ($basename, $msg);
				}
			}
		}
	}
}
sub logit { local ($file, $msg) = @_;
	if (! open (LOG, ">> $rcslog")) {  warn "can't open $rcslog: $!\n";
	} else {
		$pid = fork;	# log in background for better response time
		if (! $pid) {
			($user) = getpwuid ($>);
			print LOG &timestamp, " $file $user $msg\n"; close LOG;
			if ($pid == 0) { exit 0; }	# the child's end, if a fork occurred
		}
	}
}
sub timestamp {
   # returns current date and time in "199403011 113520" format
   local ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime;
   sprintf ("%4.4d%2.2d%2.2d %2.2d%2.2d%2.2d",
      $year+1900, $mon+1, $mday, $hour, $min, $sec);
}

# ----------------------- sorry stuff -------------------------

sub sorry {  local ($text) = @_;  # warns user of an error condition
	print STDERR "Sorry, $text\n";
}

# ----------------------- view stuff -------------------------

foreach $f ("/usr/bin/less", "/usr/bin/more") {
	if (-x $f) { $default_pager = $f; }
}
sub view {	local($title, $text) = @_;	# or ($filename) =
	if (! $text && -T $title && open(F,"< $title")) {
		$nlines = 0;
		while (<F>) { last if ($nlines++ > $maxrows); } close F;
		if ($nlines > $maxrows) {
			system (($ENV{PAGER} || $default_pager) . " \'$title\'");
		} else {
			open (F,"< $title"); undef $/; local($text)=<F>; $/="\n"; close F;
			&tiview($title, $text);
		}
	} else {
		local (@lines) = split (/\r?\n/, $text, $maxrows);
		if (($#lines - $[) < 21) {
			&tiview ($title, $text);
		} else {
			local ($safetitle); ($safetitle = $title) =~ s/[^a-zA-Z0-9]+/_/g;
			local ($tmp) = "/tmp/$safetitle.$$";
			if (! open (TMP, "> $tmp")) { warn "can't open $tmp: $!\n"; return; }
			print TMP $text;	close TMP;
			system (($ENV{PAGER} || $default_pager) . " \'$tmp\'");
			unlink $tmp;
			return 1;
		}
	}
}
sub tiview {	local ($title, $text) = @_;
	return unless $text; local ($[) = 0;
	$title =~ s/\t/ /g; local ($titlelength) = length $title;
	
	if ($size_changed) { ($maxcols, $maxrows) = &cols_and_rows(); }
	local @rows = &fmt($text, nofill=>1);
	# local @rows = &fmt($text);
	&initscr ();
	if ($titlelength > ($maxcols-35)) { &puts ("$title\r\n");
	} else { &puts ("$title   (<enter> to continue, q to clear)\r\n");
	}
	&wr_screen_tiview();
	
	for (;;) {
		$c = &getch();
		if ($c eq 'q' || $c eq "\cX" || $c eq "\cW" || $c eq "\cZ"
		|| $c eq "\cC" || $c eq "\c\\") {
			for ($il=0; $il<=(scalar @rows); $il++) { &goto(0,$il); &clrtoeol (); }
			&goto (0, 0); &endwin (); return 1;
		} elsif ($c eq "\r") {  # <enter> retains text on screen
			&clrtoeol; &goto (0, @rows+1); &endwin(); return 1;
		} elsif ($c eq "\cL") {
			&puts("\r"); &endwin; &tiview($title,$text); return 1;
		}
	}
	&endwin ();
}
sub wr_screen_tiview {
	&puts("\r");
	my $clr = "\e[K";
	&addstr(join("$clr\r\n",@rows), "\r");
	$icol = 0; $irow = scalar @rows;
	&goto ($titlelength+1, 0);
}

# -------------------------- infrastructure -------------------------

sub display_question {   my $question = shift; my %options = @_;
	# used by ask and confirm
	if ($size_changed) {($maxcols,$maxrows)=&cols_and_rows(); $size_changed=0;}
	my ($firstline, @otherlines);
	if ($options{nofirstline}) {
		@otherlines = &fmt($question);
	} else {
		($firstline,$otherlines) = split (/\r?\n/, $question, 2);
		@otherlines = &fmt($otherlines);
		if ($firstline) { &puts("$firstline "); }
	}
	if (@otherlines) {
		&puts("\r\n", join("\r\n", @otherlines), "\r");
		$icol = 0; $irow = scalar @otherlines;
		&goto(1 + length $firstline, 0);
	}
	return scalar @otherlines;
}
sub erase_next_lines { my $n = shift;
	&puts("\r\n"); return unless $n; &down($n-1); my $i=1;
	while (1) { &clrtoeol(); last if $i==$n; &up(1); $i++; }
}
sub fmt { my $text = shift; my %options = @_;
	# Used by tiview, ask and confirm; formats the text within $maxcols cols
	my (@i_words, $o_line, @o_lines, $o_length, $last_line_empty, $w_length);
	my (@i_lines, $initial_space);
	@i_lines = split (/\r?\n/, $text);
	foreach $i_line (@i_lines) {
   	if ($i_line =~ /^\s*$/) {   # blank line ?
      	if ($o_line) { push @o_lines, $o_line; $o_line=''; $o_length=0; }
      	if (! $last_line_empty) { push @o_lines,""; $last_line_empty=1; }
      	next;
   	}
   	$last_line_empty = 0;

		if ($options{nofill}) {
			push @o_lines, substr($i_line, $[, $maxcols); next;
   	}
		if ($i_line =~ s/^(\s+)//) {   # line begins with space ?
			$initial_space = $1; $initial_space =~ s/\t/   /g;
      	if ($o_line) { push @o_lines, $o_line; }
      	$o_line = $initial_space; $o_length = length $initial_space;
   	} else {
			$initial_space = '';
		}

   	@i_words = split (' ', $i_line);
   	foreach $i_word (@i_words) {
      	$w_length = length $i_word;
      	if (($o_length + $w_length) > $maxcols) {
         	push @o_lines, $o_line;
				$o_line = $initial_space; $o_length = length $initial_space;
      	}
      	if ($w_length > $maxcols) {  # chop it !
				push @o_lines, substr($i_word,$[,$maxcols); next;
			}
      	if ($o_line) { $o_line .= ' '; $o_length += 1; }
      	$o_line .= $i_word; $o_length += $w_length;
   	}
	}
	if ($o_line) { push @o_lines, $o_line; }
	return (@o_lines);  # should truncate to $maxrows ...
}
1;

__END__

# POD Documentation (perldoc or pod2html this file)
=head1 NAME

Term::Clui.pm - Perl module offering a Command-Line User Interface

=head1 SYNOPSIS

	use Term::Clui;
	$chosen = &choose('A Title', @a_list);
	if (&confirm ($text)) { &do_something; };
	$newtext = &edit($title, $text);
	&edit($filename);
	&view ($title, $text)  # if $title is not a filename
	&view ($textfile)  # if $textfile _is_ a filename

	&edit (&choose ('Edit which file ?', grep (-T, readdir D)));

=head1 DESCRIPTION

Term::Clui offers a high-level user interface to give the user of
command-line applications a consistent "look and feel".
Its metaphor for the computer is as a human-like conversation-partner,
and as each question/response is completed it is summarised onto one line,
and remains on screen, so that the history of the session gradually
accumulates on the screen and is available for review, or for cut/paste.
This user interface can therefore be intermixed with
standard applications which write to STDOUT or STDERR,
such as I<make>, I<pgp>, I<rcs> etc.

For the user, I<&choose> uses arrow keys (or hjkl) and return or q,
and I<&confirm> expects y, Y, n or N.
In general, ctrl-L redraws the (currently active bit of the) screen.
I<&edit> and I<&view> use the default EDITOR and PAGER if possible.  

It's fast, simple, and has few external dependencies.
It doesn't use I<curses> (which is a whole-of-screen interface);
it uses a small subset of vt100 sequences (up down left right normal
and reverse) which are very portable.
There is an HTML equivalent planned,
offering similarly named routines for CGI scripts.

=head1 WINDOW-SIZE

Term::Clui attempts to handle the WINCH signal.
This is still clunky, so the following describes
how it's supposed to be, rather than how it currently is.

If the window size is changed,
then as soon as the user enters the next keystroke (such as ctrl-L)
the current question/response will be redisplayed to fit the new size.

The first line of the question, the one which will remain on-screen, is
not re-formatted, but is left to be dealt with by the width of the window.
Subsequent lines are split into blank-separated words which are
filled into the available width; lines beginning with white-space
are treated as the beginning of a new indented paragraph,
individual words which will not fit onto one line are truncated,
and successive blank lines are collapsed into one.
If the question will not fit within the available rows, it is truncated.

If the available choice items in a I<&choose> overflow the screen,
then currently I<complete.pl> is invoked.  This is fine if the user knows
the item they want by its first letters, but it's not good otherwise.
It will be replaced by asking the user to enter 'clue' letters,
and as soon as the items matching them will fit onto the screen
they will be displayed as a choice.

=head1 SUBROUTINES

=over 3

=item I<ask>( $question );

Asks the user the question and returns a string answer,
with no newline character at the end.

=item I<ask_password>( $question );

Does the same with no echo, as used for password entry.

=item I<choose>( $question, @list );

Displays the question, and formats the list items onto the lines beneath it.
The user can choose an item using arrow keys (or hjkl) and return,
or cancel the choice with a 'q'.
I<choose> then returns the chosen item,
or the empty string if the choice was cancelled.

A DBM database is maintained of the question and its chosen response.
The next time the user is offered a choice with the same question,
if that response is still in the list it is highlighted
as the default; otherwise the first item is highlighted.
Different parts of the code, or different applications using I<Term::Clui.pm>
can exchange defaults simply by using the same question words,
such as "Which printer ?".  The database I<~/db/choices> is available
to be read or written if lower-level manipulation is needed.

=item I<confirm>( $question );

Asks the question, takes 'y', 'n', 'Y' or 'N' as a response.
If the $question is multi-line, after the response, all but the first
line is erased, and the first line remains on-screen with I<Yes> or I<No>
appended after it; you should therefore try to arrange multi-line
questions so that the first line is the question in short form,
and subsequent lines are explanation and elaboration.
Returns true or false.

=item I<edit>( $title, $text );  OR  I<edit>( $filename );

Uses the environment variable EDITOR ( or I<vi> :-)
Uses RCS if directory RCS/ exists

=item I<sorry>( $message );

Similar to I<warn "Sorry, $message\n";>

=item I<view>( $title, $text );  OR  I<view>( $filename );

If the I<$text> is longer than a screenful,
uses the environment variable PAGER ( or I<less> ) to display it;
if it is shorter, uses a simple built-in routine which 
expects either 'q' or I<Return> from the user.
If the user presses I<Return> the displayed text remains on the screen
and the dialogue continues after it;
if the user presses 'q' the text is erased.

=back

=head1 DEPENDENCIES

It requires Exporter, flush.pl, and (currently) complete.pl,
which are all core Perl.
It uses Term::Size.pm if it's available;
if not, it tries `tput` before guessing 80x24.

=head1 ENVIRONMENT

Uses the environment variables HOME, LOGDIR, EDITOR and PAGER,
if they are set.

=head1 AUTHOR

Peter J Billam <peter@pjb.com.au>

=head1 CREDITS

Based on some old perl 4 libraries, I<ask.pl>, I<choose.pl>,
I<confirm.pl>, I<edit.pl>, I<sorry.pl> and I<view.pl>,
which were in turn based on some even older curses-based programs in I<C>.

=head1 SEE ALSO

http://www.pjb.com.au/ , perl(1), http://www.cpan.org/SITES.html

=cut
