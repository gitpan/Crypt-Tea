#! /usr/bin/perl
#########################################################################
#        This Perl script is Copyright (c) 2001, Peter J Billam         #
#               c/o P J B Computing, www.pjb.com.au                     #
#                                                                       #
#     This program is free software; you can redistribute it and/or     #
#            modify it under the same terms as Perl itself.             #
#########################################################################
use Crypt::Tea;

my $text = <<'EOT';
Hier lieg' ich auf dem Frülingshügel:
die Wolke wird mein Flügel,
ein Vogel fliegt mir voraus.

Ach, sag' mir, all-einzige Liebe,
wo du bleibst, daß ich bei dir bliebe !
doch du und die Lüfte, ihr habt kein Haus.

Der Sonnenblume gleich steht mein Gemüthe offen,
sehnend, sich dehnend in Lieben und Hoffen.
Frühling, was bist du gewillt ?
wenn werd' ich gestillt ?

Die Wolke seh' ich wandeln und den Fluß,
es dringt der Sonne goldner Kuß tief bis in's Geblüt hinein;
die Augen, wunderbar berauschet, thun, als scliefen sie ein,
nur noch das Ohr der Ton der Biene lauschet.

Ich denke Diess und denke Das,
ich sehne mich, und weiss nicht recht, nach was:
halb ist es Lust, halb ist es Klage;
mein Herz, o sage,
was webst du für Erinnerung
in goldnen grüner Zweige Dämmerung ?

Alte, unnennbare Tage !
EOT

$key1 = &asciidigest ("G $$ ". time);
$key2 = &asciidigest ("Arghhh... " . time ."Xgloopiegleep $$");

my $p1 = <<EOT;
If you are reading this paragraph, it has been successfully
encrypted by <I>Perl</I> and decrypted by <I>JavaScript</I>.
The password used was "$key1".
A localised error in the cyphertext will cause about
16 bytes of binary garbage to appear in the plaintext output.
EOT
my $p2 = <<EOT;
And if you are reading this one, it has been successfully
encrypted by <I>Perl</I>, decrypted by <I>JavaScript</I>,
and then, using a different password "$key2",
re-encrypted and re-decrypted by <I>JavaScript</I>.
EOT

my $d = &asciidigest ($text); 
if ($d eq '5sO762E_kw3WK--EiHhHiA') {
	print "asciidigest OK ...\n";
} else {
	print "ERROR: asciidigest was $d, should be 5sO762E_kw3WK--EiHhHiA\n";
	exit 1;
}

my $c = &encrypt ($text, $key1); 
my $p = &decrypt ($c, $key1);
if ($p eq $text) {
	print "encrypt and decrypt OK ...\n";
} else {
	print "ERROR: encrypt and decrypt failed: encrypt was\n$c\n";
	exit 1;
}
$c =~ tr/-/+/;
$p = &decrypt ($c, $key1);
if ($p eq $text) {
	print "version1-compatible decrypt OK ...\n";
} else {
	print "ERROR: version1-compatible decrypt failed: encrypt was\n$c\n";
	exit 1;
}

if (! open (F, '>test.html')) { die "Sorry, can't open test.html: $!\n"; }
$ENV{REMOTE_ADDR} = '123.321.123.321';  # simulate CGI context
$c1 = &encrypt ($p1, $key1); 
$c2 = &encrypt ($p2, $key1); 
print F "<HTML><HEAD><TITLE>test.html</TITLE>\n",&tea_in_javascript(),<<'EOT';
</HEAD><BODY BGCOLOR="#FFFFFF">
<P><H2>
This page is a test of the JavaScript side of
<A HREF="http://www.pjb.com.au/comp/tea.html">Crypt::Tea.pm</A>
</H2></P>

<HR>
<H3>First a quick check of the various JavaScript functions . . .</H3>
<P>If any of these functions do not return what they should,
please use your mouse to cut-and-paste all the bit in
<CODE>constant-width</CODE> font,
and paste it into an email to
<A HREF="http://www.pjb.com.au/comp/contact.html">Peter Billam</A>
</P>
<PRE>
<SCRIPT LANGUAGE="JavaScript"> <!--
document.write('Crypt::Tea 2.00 on ' + navigator.appName
 + ' ' + navigator.appVersion);
// -->
</SCRIPT>

binary2ascii(1234567,7654321,9182736,8273645)
<SCRIPT LANGUAGE="JavaScript"> <!--
var blocks = new Array();
blocks[0]=1234567; blocks[1]=7654321; blocks[2]=9182736; blocks[3]=8273645;
document.write('   returns ' + binary2ascii(blocks));
// -->
</SCRIPT>
 should be ABLWhwB0y7EAjB4QAH4-7Q

ascii2binary('GUQEX19vG3csxE9v2Vtwh') returns 
<SCRIPT LANGUAGE="JavaScript"> <!--
var b = new Array; b = ascii2binary('GUQEX19vG3csxE9v2Vtwh');
var ib = 0;  var lb = b.length;
document.write('   returns ');
while (1) {
 if (ib >= lb) break;
 document.write(b[ib] + ', ');
 ib++;
}
// -->
</SCRIPT>
 should be 423887967, 1601117047, 751062895, -648318844,

str2bytes('GUQEX19vG3csxE9')
<SCRIPT LANGUAGE="JavaScript"> <!--
var b = new Array; b = str2bytes('GUQEX19vG3csxE9');
var ib = 0;  var lb = b.length;
document.write('   returns ');
while (1) {
 if (ib >= lb) break;
 document.write(b[ib] + ', ');
 ib++;
}
// -->
</SCRIPT>
 should be 71, 85, 81, 69, 88, 49, 57, 118, 71, 51, 99, 115, 120, 69, 57,

bytes2str(88, 49, 118, 99, 115, 69)
<SCRIPT LANGUAGE="JavaScript"> <!--
var b = new Array;
b[0]=88; b[1]=49; b[2]=118; b[3]=99; b[4]=115; b[5]=69;
document.write('   returns ' + bytes2str(b));
// -->
</SCRIPT>
 should be X1vcsE

ascii2bytes('GUQEX19vG3csxE9v2') returns
<SCRIPT LANGUAGE="JavaScript"> <!--
var b = new Array; b = ascii2bytes('GUQEX19vG3csxE9v2');
var ib = 0;  var lb = b.length;
document.write('   returns ');
while (1) {
 if (ib >= lb) break;
 document.write(b[ib] + ', ');
 ib++;
}
// -->
</SCRIPT>
 should be 25, 68, 4, 95, 95, 111, 27, 119, 44, 196, 79, 111, 217,

bytes2str(88, 49, 118, 99, 115, 69)
<SCRIPT LANGUAGE="JavaScript"> <!--
var b = new Array;
b[0]=88; b[1]=49; b[2]=118; b[3]=99; b[4]=115; b[5]=69;
document.write('   returns ' + bytes2ascii(b));
// -->
</SCRIPT>
 should be WDF2Y3NF

bytes2blocks(88, 49, 118, 99, 115, 69)
<SCRIPT LANGUAGE="JavaScript"> <!--
var by = new Array;
by[0]=88; by[1]=49; by[2]=118; by[3]=99; by[4]=115; by[5]=69;
var bl = bytes2blocks(by); var ibl = 0;  var lbl = bl.length;
document.write('   returns ');
while (1) {
 if (ibl >= lbl) break;
 document.write(bl[ibl] + ', ');
 ibl++;
}
// -->
</SCRIPT>
 should be 1479636579, 1933901824,

digest_pad(88, 49, 118, 99, 115, 69)
<SCRIPT LANGUAGE="JavaScript"> <!--
var by = new Array;
by[0]=88; by[1]=49; by[2]=118; by[3]=99; by[4]=115; by[5]=69;
var bl = digest_pad(by); var ibl = 0;  var lbl = bl.length;
document.write('   returns ');
while (1) {
 if (ibl >= lbl) break;
 document.write(bl[ibl] + ', ');
 ibl++;
}
// -->
</SCRIPT>
 should be 9, 88, 49, 118, 99, 115, 69, 0, 0, 0, 0, 0, 0, 0, 0, 0,

pad(88, 49, 118, 99, 115, 69)
<SCRIPT LANGUAGE="JavaScript"> <!--
var by = new Array;
by[0]=88; by[1]=49; by[2]=118; by[3]=99; by[4]=115; by[5]=69;
var bl = pad(by); var ibl = 0;  var lbl = bl.length;
document.write('   returns ');
while (1) {
 if (ibl >= lbl) break;
 document.write(bl[ibl] + ', ');
 ibl++;
}
// -->
</SCRIPT>
 should be ??, 88, 49, 118, 99, 115, 69, ??,
 but note that the first and last bytes are random

unpad(121, 88, 49, 118, 99, 115, 69, 162)
<SCRIPT LANGUAGE="JavaScript"> <!--
var by = new Array;
by[0]=121;by[1]=88;by[2]=49;by[3]=118;by[4]=99;by[5]=115;by[6]=69;by[7]=162;
var bl = unpad(by); var ibl = 0;  var lbl = bl.length;
document.write('   returns ');
while (1) {
 if (ibl >= lbl) break;
 document.write(bl[ibl] + ', ');
 ibl++;
}
// -->
</SCRIPT>
 should be 88, 49, 118, 99, 115, 69,

asciidigest('Gloop gleep glorp glurp')
<SCRIPT LANGUAGE="JavaScript"> <!--
document.write('   returns ' + asciidigest('Gloop gleep glorp glurp'));
// -->
</SCRIPT>
 should be j4u8AWK2n6A4abYVtUAihw

binarydigest('Gloop gleep glorp glurp', 'ksmZjyFSBRc3_cHLUag9zA')
<SCRIPT LANGUAGE="JavaScript"> <!--
var bl = binarydigest('Gloop gleep glorp glurp', 'ksmZjyFSBRc3_cHLUag9zA');
var ibl = 0;  var lbl = bl.length;
document.write('   returns ');
while (1) {
 if (ibl >= lbl) break;
 document.write(bl[ibl] + ', ');
 ibl++;
}
// -->
</SCRIPT>
 should be -1886667775, 1656135584, 946451989, -1254088057,

xor_blocks((2048299521, 595110280), (-764348263, -554905533))
<SCRIPT LANGUAGE="JavaScript"> <!--
var bl1 = new Array(); var bl2 = new Array();
bl1[0]=2048299521; bl1[1]=595110280; bl2[0]=-764348263; bl2[1]=-554905533;
var bl = xor_blocks(bl1,bl2);
var ibl = 0;  var lbl = bl.length;
document.write('   returns ');
while (1) {
 if (ibl >= lbl) break;
 document.write(bl[ibl] + ', ');
 ibl++;
}
// -->
</SCRIPT>
 should be -1469683048, -40601141,

tea_code((2048299521,595110280),
  (-764348263,554905533,637549562,-283747546))
<SCRIPT LANGUAGE="JavaScript"> <!--
var v = new Array(); var key = new Array();
v[0]=2048299521; v[1]=595110280;
key[0]=-764348263; key[1]=554905533;
key[2]=637549562; key[3]=-283747546;
var bl = tea_code(v,key);
var ibl = 0;  var lbl = bl.length;
document.write('   returns ');
while (1) {
 if (ibl >= lbl) break;
 document.write(bl[ibl] + ', ');
 ibl++;
}
// -->
</SCRIPT>
 should be -451692928, 1589210186,

tea_decode((2048299521,595110280),
  (-764348263,554905533,637549562,-283747546))
<SCRIPT LANGUAGE="JavaScript"> <!--
var v = new Array(); var key = new Array();
v[0]=2048299521; v[1]=595110280;
key[0]=-764348263; key[1]=554905533;
key[2]=637549562; key[3]=-283747546;
var bl = tea_decode(v,key);
var ibl = 0;  var lbl = bl.length;
document.write('   returns ');
while (1) { 
 if (ibl >= lbl) break; 
 document.write(bl[ibl] + ', ');
 ibl++;
}
// -->
</SCRIPT>
 should be -257148566, -1681954940,

</PRE>

EOT
print F <<EOT;
<HR><H3>Now a test of JavaScript decryption . . .</H3><P><FONT SIZE='+1'>
<SCRIPT LANGUAGE="JavaScript"> <!--
document.write(decrypt('$c1','$key1'));
// -->
</SCRIPT>
</FONT></P>

<HR><H3>Now a test of JavaScript encryption . . .</H3><P><FONT SIZE='+1'>
<SCRIPT LANGUAGE="JavaScript"> <!--
var c2 = encrypt(decrypt('$c2','$key1'),'$key2');
document.write(decrypt(c2,'$key2'));
// -->
</SCRIPT>
</FONT></P>
<HR></BODY></HTML>
EOT
close F;

warn "Now use a JavaScript-capable browser to view test.html ...\n";

exit 0;

__END__

=pod

=head1 NAME

test.pl - Perl script to test Crypt::Tea.pm

=head1 SYNOPSIS

  make test
  netscape file:test.html

=head1 DESCRIPTION

This tests the Crypt::Tea.pm module.

=head1 AUTHOR

Peter J Billam  http://www.pjb.com.au/comp/contact.html

=head1 SEE ALSO

http://www.pjb.com.au/ http://www.cpan.org perl(1).

=cut

