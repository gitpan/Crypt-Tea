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

sub which { my $file = $_[$[];   # looks for executables, Perl libraries
   return '' unless $file;
   my $slash = (-f "c:\autoexec.bat") ? '\\' : '/';
	my $absfile;
   if ($file =~ /\.p[lm]$/) {   # perl library or module ?
      foreach $dir (@INC) {
         $absfile = "$dir$slash$file";   return $absfile if -r $absfile;
      }
   } else {   # executable ?
      foreach $dir (split (":", $ENV{PATH})) {
         $absfile = "$dir$slash$file";   return $absfile if -x $absfile;
      }
   }
}
1;
