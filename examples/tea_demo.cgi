#! /usr/bin/perl
#########################################################################
#        This Perl script is Copyright (c) 2004, Peter J Billam         #
#               c/o P J B Computing, www.pjb.com.au                     #
#                                                                       #
#     This script is free software; you can redistribute it and/or      #
#            modify it under the same terms as Perl itself.             #
#########################################################################
use Crypt::Tea;

my $username = 'james';
my $key      = 'bond';

# extract the FORM data ...
my ($request_method, $query_string, @key_value_pairs, %DAT);
$request_method = $ENV{'REQUEST_METHOD'};
if ($request_method eq 'GET') {
	$query_string = $ENV{'QUERY_STRING'};
} elsif ($request_method eq 'POST') {
	read (STDIN, $query_string, $ENV{'CONTENT_LENGTH'});
} else {
	&header('Sorry . . .'); &sorry("Unknown request method $request_method");
}
@key_value_pairs = split (/&/, $query_string);
foreach $key_value (@key_value_pairs) {
	my ($k, $v) = split (/=/, $key_value); $v =~ tr/+/ /;
	$v =~ s/%([\dA-Fa-f][\dA-Fa-f])/pack ("C", hex($1))/eg;
	if (! defined($DAT{$k})) { $DAT{$k} = $v;
	} else { $DAT{$k} = join ("\0", $DAT{$k}, $v);
	}
}
#-----------------------------------------------------------------------

&header($ENV{SCRIPT_NAME});

if (! $DAT{cyphertext}) {
	my $cyphertext = &encrypt ( <<EOT , $key );
<P>Latest gossip: Fred Bloggs seems OK, but don't trust his sister
Gina, don't know who she's working for; could be unwitting.<BR>
Also, AH may have been sprung - be circumspect.</P>

<FORM NAME="covert" ACTION="$ENV{SCRIPT_NAME}" METHOD="post">
<INPUT TYPE="hidden" NAME="username" VALUE="$username">
<INPUT TYPE="hidden" NAME="cyphertext" VALUE="">
</FORM>

<FORM NAME="overt" onSubmit="return submitter(this)">
<TABLE>
<TR><TH>Contact</TH><TD><INPUT TYPE="text" NAME="contact"></TD></TR>
<TR><TH>Date   </TH><TD><INPUT TYPE="text" NAME="date">   </TD></TR>
<TR><TH>Comment</TH><TD><INPUT TYPE="text" NAME="comment"></TD></TR>
</TABLE>
<INPUT TYPE="submit" NAME="File Report">
</FORM>

EOT
	print &tea_in_javascript();
	print "Welcome $username . . . (Hint: your password is <I>$key</I>)\n";
	print <<'EOT';
<SCRIPT LANGUAGE="JavaScript"> <!--
var key = prompt("Password ?","");
function submitter(form) {
  var plaintext = '';
  for (var i=0; i<form.length; i++) {
    var e = form.elements[i];
    plaintext += (e.name+"\f"+ e.value+"\f");
  }
  document.covert.cyphertext.value = encrypt (plaintext, key);
  document.covert.submit();
  return false;
}
EOT
	print <<EOT;
 document.write(decrypt("$cyphertext", key));
// -->
</SCRIPT>
EOT

} else {   # we have some cyphertext :-)
	my @contents = split ("\f", decrypt($DAT{cyphertext}, $key));

	my $new_plaintext = "$username, you submitted the following report<BR>\n";
   while (1) {
		my $k = shift @contents; my $v = shift @contents; last unless $k;
		$new_plaintext .= "$k: $v<BR>\n";
	}

	my $new_cyphertext = &encrypt ($new_plaintext, $key);
	print &tea_in_javascript(), <<EOT;
<SCRIPT LANGUAGE="JavaScript"> <!--
var key = prompt("Password ?","");
document.write("$plaintext");
document.write(decrypt("$new_cyphertext", key));
// -->
</SCRIPT>
EOT
}

&footer(); exit 0;

#-----------------------------------------------------------------------
sub header { my $title = $_[$[] || $ENV{'SCRIPT_NAME'};
	print <<EOT;
Content-type: text/html

<HTML><HEAD><TITLE>$title</TITLE>
</HEAD><BODY BGCOLOR="#FFFFFF">
<P ALIGN="center"><FONT SIZE="+2"><B><I>$title</I></B></FONT></P><HR>
EOT
}
sub sorry { print '<B>Sorry, ', $_[$[], '</B>'; &footer(); exit 0; }
sub footer { print "<HR></BODY></HTML>\n"; }

__END__

=pod

=head1 NAME

tea_demo.cgi - CGI script to submit an encrypted form using Crypt::Tea

=head1 SYNOPSIS

Move this script into a cgi-bin directory, make it executable,
and point a JavaScript-capable browser at it.

=head1 DESCRIPTION

This script should get you started in using Crypt::Tea.
It demonstrates viewing encrypted page content,
and submitting encrypted form content.

Consult the source code, the Crypt::Tea documentation,
and the View-Source button in your browser.

=head1 AUTHOR

Peter J Billam  www.pjb.com.au/comp/contact.html

=head1 SEE ALSO

perldoc Crypt::Tea,
http://www.pjb.com.au/comp/tea.html, perl(1).

=cut

