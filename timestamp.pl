#########################################################################
#       This Perl library is Copyright (c) 1994, Peter J Billam         #
#      c/o P J B Computing, 5 Scott St, Glebe TAS 7000, Australia       #
#                                                                       #
# Permission is granted  to any individual or institution to use, copy, #
# modify or redistribute this software, so long as it is not resold for #
# profit,  and provided this notice is retained.   Neither Peter Billam #
# nor  P J B Computing  make any representations  about the suitability #
# of this software for any purpose. It is provided "as is", without any #
# express or implied warranty.                                          #
#     The latest version of this and of all other P J B software can be #
# ordered from P J B Computing at the above address.                    #
#      P J B Computing is pleased to offer its services in installation #
# or customisation of this script,  or in Unix System Administration or #
# IP Networking.                                                        #
#########################################################################

package pjb;

sub main'timestamp {
   # returns current date and time in "199403011 113520" format
   local ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime;
   sprintf ("%4.4d%2.2d%2.2d %2.2d%2.2d%2.2d",
      $year+1900, $mon+1, $mday, $hour, $min, $sec);
}
sub main'datestamp {
   # returns current date in "19940311" format
   local ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime;
   sprintf ("%4.4d%2.2d%2.2d", $year+1900, $mon+1, $mday);
}
sub main'neatdate {
   # converts "940311" or "19940311" to "11mar1994", or "9403" to "mar1994"
   local ($date, $yy, $mm, $dd, $mon);
   $date = shift(@_);
   $date =~ s/^9/199/;
   ($yy, $mm, $dd) = $date =~ /(\d\d\d\d)(\d\d)((\d\d)?)/;
   $mon = ("jan","feb","mar","apr","may","jun",
           "jul","aug","sep","oct","nov","dec")[$mm - 1];
   $dd =~ s/^0/ /;
   if ($dd) { return ("$dd$mon$yy"); }
   elsif ($mm) { return ("$mon$yy"); }
   else { return ($date); }
}
1;
