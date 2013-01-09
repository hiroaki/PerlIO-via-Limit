use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'          => 'PerlIO::via::Limit',
    'VERSION_FROM'  => 'lib/PerlIO/via/Limit.pm', # finds $VERSION
    'LICENSE'       => 'perl',
    'PREREQ_PM'     => {
        'Test::More'    => '0.32',
        'PerlIO::via'   => '0',
    },
);
