use ExtUtils::MakeMaker;

WriteMakefile(
	NAME      => 'Crypt::Tea',
	VERSION_FROM => 'Tea.pm',
	EXE_FILES => [ glob "bin/*" ],
	AUTHOR    => 'PJB, Peter Billam, computing@pjb.com.au',
	ABSTRACT  => 'Tiny Encryption Algorithm in Perl and JavaScript',
	dist      => {COMPRESS=>'gzip -9f', SUFFIX => 'gz'},
);
