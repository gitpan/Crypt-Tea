package main;
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

package vt100;
$bsd = (-f "/kernel" || -f "/vmunix" || -f "/386bsd");

sub main'addch  { print TTY @_; }
sub main'addstr { print TTY @_; }
sub main'attrset {
   local ($attr) = @_;
   if (! $attr) {
      print TTY "\033[0m";
   } else {
      if ($attr & $'A_BOLD)      { print TTY "\033[1m" };
      if ($attr & $'A_REVERSE)   { print TTY "\033[7m" };
      if ($attr & $'A_UNDERLINE) { print TTY "\033[4m" };
   }
}
sub main'beep     { print TTY "\07"; }
sub main'clear    { print TTY "\033[H\033[J"; }
sub main'clrtoeol { print TTY "\033[K"; }
sub main'curs_set {
# # ifndef BSD386
#    if (vis) fprintf(tty, "\033[?25h");
#    else fprintf(tty, "\033[?25l");
# # endif
}
sub main'endwin {
   print TTY "\033[0m";
   require 'flush.pl'; &flush (TTY);
   close TTY; close TTYIN;
   if ($^O eq 'FreeBSD') {
      system("stty $stty </dev/tty") if $stty;
   } else {
      system("stty $stty </dev/tty >/dev/tty") if $stty;
   }
   &'curs_set();
}
sub main'getch {
   local ($debug) = 0;
   local ($c);
   $c = getc(TTYIN);
   if ($debug) { print STDERR "getch line4: c = $c = ",unpack('c',$c),"\n\r"; }
   if ($c eq "\033") {
      $c = getc(TTYIN);
      if ($debug) {print STDERR "line7: c = $c = ",unpack('c',$c),"\n\r"; }
      if ($c eq "A") { return($'KEY_UP); }
      if ($c eq "B") { return($'KEY_DOWN); }
      if ($c eq "C") { return($'KEY_RIGHT); }
      if ($c eq "D") { return($'KEY_LEFT); }
      if ($c eq "5") { getc(TTYIN); return($'KEY_PPAGE); }
      if ($c eq "6") { getc(TTYIN); return($'KEY_NPAGE); }
      if ($c eq "Z") { return($'KEY_BTAB); }
      if ($c eq "[") {
         $c = getc(TTYIN);
         if ($debug) {print STDERR "line17: c = $c = ",unpack('c',$c),"\n\r"; }
         if ($c eq "A") { return($'KEY_UP); }
         if ($c eq "B") { return($'KEY_DOWN); }
         if ($c eq "C") { return($'KEY_RIGHT); }
         if ($c eq "D") { return($'KEY_LEFT); }
         if ($c eq "5") { getc(TTYIN); return($'KEY_PPAGE); }
         if ($c eq "6") { getc(TTYIN); return($'KEY_NPAGE); }
         if ($c eq "Z") { return($'KEY_BTAB); }
         return($c);
      }
      return($c);
   } elsif ($c == oct(0217)) {
      $c = getc(TTYIN);
      if ($debug) {print STDERR "line30: c = $c = ",unpack('c',$c),"\n\r"; }
      if ($c eq "A") { return($'KEY_UP); }
      if ($c eq "B") { return($'KEY_DOWN); }
      if ($c eq "C") { return($'KEY_RIGHT); }
      if ($c eq "D") { return($'KEY_LEFT); }
      return($c);
   } elsif ($c == oct(0233)) {
      $c = getc(TTYIN);
      if ($debug) {print STDERR "line38: c = $c = ",unpack('c',$c),"\n\r"; }
      if ($c eq "A") { return($'KEY_UP); }
      if ($c eq "B") { return($'KEY_DOWN); }
      if ($c eq "C") { return($'KEY_RIGHT); }
      if ($c eq "D") { return($'KEY_LEFT); }
      if ($c eq "5") { getc(TTYIN); return($'KEY_PPAGE); }
      if ($c eq "6") { getc(TTYIN); return($'KEY_NPAGE); }
      if ($c eq "Z") { return($'KEY_BTAB); }
      return($c);
   } else {
      return($c);
   }
}
sub main'puts { print TTY @_;
}
sub main'bell { print TTY "\007";
}
sub up { local ($n) = @_[$[] || 1;
   local ($i); for ($i=0;$i<$n;$i++) {print TTY "\033[A";}
}
sub down { local ($n) = @_[$[] || 1;
   local ($i); for ($i=0;$i<$n;$i++) {print TTY "\033[B";}
}
sub right { local ($n) = @_[$[] || 1;
   local ($i); for ($i=0;$i<$n;$i++) {print TTY "\033[C";}
}
sub left { local ($n) = @_[$[] || 1;
   local ($i); for ($i=0;$i<$n;$i++) {print TTY "\033[D";}
}
sub main'gets {   # allows editing with LeftArrow, RightArrow and Backspace
   local (@chars, $i, $c, $ntoright);
   $i = $[;  # start at the start
   while () {
      $c = &main'getch();
      if ($c eq $'KEY_ENTER) { &main'puts("\r"); return join ("", @chars);
      } elsif ($c eq "\t") { &main'bell();
      } elsif ($c eq $'KEY_UP) {
      } elsif ($c eq $'KEY_DOWN) {
      } elsif ($c eq $'KEY_LEFT) {
         if ($i > $[) { &left(1); $i--; }
      } elsif ($c eq $'KEY_RIGHT) {
         if ($i < $#chars) { &right(1); $i++; }
      } elsif ($c eq "\cH") {
         if ($i > $[) {
            &left(1); $i--; splice @chars, $i, 1;
            # must redraw remainder of line (if any) and left back again
            if ($#chars > $i) {
               &main'puts (join("", @chars[($i)..$#chars]) . " ");
               &left($#chars-$i+2);
            }
         }
      } elsif ($c eq "\cL") {
      } elsif ($c =~ /[\s\S]/) {
         splice @chars, $i, 0, $c;
         &main'puts("$c"); $i++;
         # must redraw remainder of line (if any) and left back again
         if ($#chars > $i) {
            &main'puts (join("", @chars[($i)..$#chars]));
            &left($#chars-$i+1);
         }
      }
   }
}
sub main'initscr {
   local ($debug) = 0;
   open(TTY, ">/dev/tty")  || (warn "Can't write /dev/tty: $!\n", return 0);
   $stty = `stty -g`; chop $stty;
   open(TTYIN, "</dev/tty") || (warn "Can't read /dev/tty: $!\n", return 0);

   if ($^O eq 'FreeBSD') {
      system("stty -echo -icrnl raw </dev/tty");
   } else {
      system("stty -echo -icrnl raw </dev/tty >/dev/tty");
   }
   # system("stty -echo -icrnl raw </dev/tty");
   # system("stty -echo -icrnl raw");
   # if ($bsd) { system "stty cbreak </dev/tty >/dev/tty 2>&1";
   # } else { system "stty", '-icanon'; system "stty", 'eol', "\001";
   # }
   require 'flush.pl'; &flush (TTY);
   select((select(TTY), $| = 1)[$[]);
   $cols = `tput cols` || 80;  $cols -= 2;
   if ($^O eq 'linux') {
      $rows = (`tput lines` + 0) || 24;
   } else {
      $rows = (`tput rows` + 0) || 24;
   }
}
sub main'keypad { }
sub main'move { local ($ix,$iy) = @_; printf TTY "\033[%d;%dH",$iy+1,$ix+1; }
sub main'beep { print TTY "\07"; }
sub main'refresh { }
1;
