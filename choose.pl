# choose - a stripped-down version only doing the vt interface
# usage: require 'choose.pl'; $chosen = &choose('A Title', @a_list);
#
#########################################################################
#        This Perl library is Copyright (c) 2000, Peter J Billam        #
#     c/o P J B Computing, GPO Box 669, Hobart TAS 7001, Australia      #
#                                                                       #
# Permission is granted  to any individual or institution to use, copy, #
# modify or redistribute this software, so long as it is not resold for #
# profit,  and provided this notice is retained.   Neither Peter Billam #
# nor  P J B Computing  make any representations  about the suitability #
# of this software for any purpose. It is provided "as is", without any #
# express or implied warranty.                http://www.pjb.com.au     #
#########################################################################

package choose;
sub main'choose {  local ($title, @list) = @_;
	grep (($_ =~ s/\n$//) && 0, @list);	# chop final \n if any

	return unless @list;
	local ($irow, %irow, $icol, %icol, $icell);
	local ($up, $down, $right, $left) = ("\e[A", "\e[B", "\e[C", "\e[D");
	# local ($home) = $ENV{'HOME'} || $ENV{'LOGDIR'} || (getpwuid($<))[7];
	# mkdir ("$home".$main'slash||'/'."db", 0750);
	mkdir ("db", 0750); my $dbfile = "db/choices";
	print "$title" if $title;
	local ($choice);
	if ($title && dbmopen (%CHOICES, $dbfile, 0600)) {
		$choice = $CHOICES{$title};
		dbmclose %CHOICES;
	}
		
	$ncols = `tput cols`;
	if ($ncols) { $ncols -= 2; } else { $ncols = 78; }
	$maxrows = `tput lines`;
	if ($maxrows) { $maxrows -= 2; } else { $maxrows = 23; }
	$irow = 1; $icol = 0;
	$this_cell = $[;
	for ($icell=$[; $icell <= $#list; $icell++) {
		$l[$icell] = length ($list[$icell]) + 2;
		if (($icol + $l[$icell]) >= $ncols ) { $irow++; $icol = 0; }
		$irow[$icell] = $irow; $icol[$icell] = $icol;
		$icol += $l[$icell];
		if ($list[$icell] eq $choice) { $this_cell = $icell; }
	}
	$nrows = $irow;
	if ($nrows > $maxrows) { # if too many for one screen, use complete.pl
		require 'complete.pl';
		return &Complete(" (TAB to complete, ^D to list) ", @list);
	}

	require "vt100.pl";
	&'initscr ();
	print "\r\n" if $title;
	$icol = 0; $irow = 1;
	&wr_screen ();
	&wr_cell ($this_cell);
	for (;;) {
		last unless $c = &'getch ();
		if ($c eq "q" || $c eq "\cD") {
			for ($ir=0; $ir<=$nrows; $ir++) { &goto(0,$ir); &'clrtoeol (); }
			&goto (0, 0);
			&'refresh();
			&'endwin ();
			return wantarray ? () : undef;
		} elsif ((($c eq " ") || ($c eq "\t")) && ($this_cell < $#list)) {
			$this_cell++; &wr_cell($this_cell-1); &wr_cell($this_cell); 
		} elsif ((($c eq "l") || ($c eq $'KEY_RIGHT)) && ($this_cell < $#list)
			&& ($irow[$this_cell] == $irow[$this_cell+1])) {
			$this_cell++; &wr_cell($this_cell-1); &wr_cell($this_cell); 
		} elsif ((($c eq "\cH") || ($c eq $'KEY_BTAB)) && ($this_cell > $[)) {
			$this_cell--; &wr_cell($this_cell+1); &wr_cell($this_cell); 
		} elsif ((($c eq "h") || ($c eq $'KEY_LEFT)) && ($this_cell > $[)
			&& ($irow[$this_cell] == $irow[$this_cell-1])) {
			$this_cell--; &wr_cell($this_cell+1); &wr_cell($this_cell); 
		} elsif ((($c eq "j") || ($c eq $'KEY_DOWN)) && ($irow < $nrows)) {
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
		} elsif ((($c eq "k") || ($c eq $'KEY_UP)) && ($irow > 1)) {
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
		} elsif ($c eq "\cL") { &wr_screen ();
		} elsif ($c eq "\r") {
			for ($ir=1; $ir<=$nrows; $ir++) { &goto(0,$ir); &'clrtoeol (); }
			if ($choose'vanish) {
				&goto (0,0);
			} else {
				&goto (length($title)+2,0); &'addstr($list[$this_cell] . "\n\r");
			}
			&'clrtoeol ();
			&'refresh();
			&'endwin ();
			if ($title && dbmopen (%CHOICES, $dbfile, 0600)) {
				$CHOICES{$title} = $list[$this_cell];
				dbmclose %CHOICES;
			}
			return wantarray ? ($list[$this_cell]) : $list[$this_cell];
		}
	}
	&'refresh ();
	&'endwin ();
}

sub wr_screen {
	&'addstr ("\r");	$icol = 0;
	for ($icell= $[; $icell <=$#list; $icell++) { &wr_cell ($icell); }
	&'refresh ();
}
sub wr_cell { local ($icell) = @_;
	&goto ($icol[$icell], $irow[$icell]);
	if ($marked[$icell]) { &'attrset($'A_BOLD); }
	if ($icell == $this_cell) { &'attrset($'A_REVERSE); }
	local ($no_tabs) = $list[$icell];
	$no_tabs =~ s/\t/ /;
	$no_tabs =~ s/^(.{1,77}).*/\1/;
	&'addstr(" $no_tabs ");
	&'attrset($'A_NORMAL);
	# $icol += $l[$icell];
	$icol += length ($no_tabs) + 2;
}
sub goto { local ($newcol, $newrow) = @_;
	if ($newcol > $icol) { &'addstr ($right x ($newcol - $icol));
	} elsif ($newcol < $icol) { &'addstr ($left x ($icol - $newcol));
	}
	$icol = $newcol;
	if ($newrow > $irow) { &'addstr ("\n" x ($newrow - $irow));
	} elsif ($newrow < $irow) { &'addstr ($up x ($irow - $newrow));
	}
	$irow = $newrow;
}
1;
