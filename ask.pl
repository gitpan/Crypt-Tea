# ask - a language-independent and UI-independent general-purpose asker.
# usage: require 'ask.pl'; $response = &ask('question ?');
#        &mail (&ask ('On what subject ?'), $text, $to);
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

package ask;
sub main'silentask { local ($question) = @_;  # no echo - use for passwords
   local ($silent) = 'yes';   &main'ask ($question);
}
sub main'ask { local ($question) = @_;   # returns a one-line text-entry answer
   return '' unless $question;
   if (0 && $ENV{'DISPLAY'} && !$ENV{PREFERVT}) {   # X-server ?
      require 'which.pl';  $wishprog = &main'which("wish");
      if ($wishprog) {
         return `$wishprog <<'EOT'
source /home/pjb/tlib/ask.tk
ask reply {$question}; puts -nonewline \$reply; destroy .
EOT
`;
      } else {
         warn "sorry, no X\n";
      }
   } else {
      require "vt100.pl";
      &'initscr();
      &'addstr(join(" ", @_), " ");

      local ($i) = 0;   # cursor position within string
      local ($n) = 0;   # length of string
      local (@s) = '';  # list of characters in string

      for (;;) {
         $c = &'getch();
         if ($c eq "\r") { &'addstr ("\r\n"); last;
         } elsif ($c eq $'KEY_LEFT) {
				if ($i > 0) { $i--; &'addch ("\010"); }
         } elsif ($c eq $'KEY_RIGHT) {
            if ($i < $n) { &'addch ($silent ? "x" : $s[$i]); $i++; }
         } elsif (($c eq "\cH") || ($c eq "\c?")) {
				if ($i > 0) {
            	$n--; $i--;
            	splice(@s, $i, 1);
            	&'addch ("\e[D");
            	foreach $j ($i .. $n) { print "$s[$j]"; }
            	&'clrtoeol(); print "\cH" x ($n - $i);
				}
         } elsif ($c !~ /[\000-\031]/) {
            splice(@s, $i, 0, $c);
            $n++; $i++; &'addch($silent ? "x" : $c);
            foreach $j ($i .. $n) { print "$s[$j]"; }
            &'clrtoeol(); &'addstr ("\010" x ($n - $i));
         }
      }
      &'endwin(); return join("", @s);
   }
}
1;
