use ExtUtils::MakeMaker;

WriteMakefile(
    NAME            => 'Crypt::TEA',
    OBJECT          => 'TEA.o _tea.o',
    VERSION_FROM    => 'TEA.pm',
    ABSTRACT_FROM   => 'TEA.pm',
);
