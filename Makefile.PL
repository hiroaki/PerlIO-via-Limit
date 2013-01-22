use ExtUtils::MakeMaker;
WriteMakefile(
    'AUTHOR'        => 'WATANABE Hiroaki <hwat@cpan.org>',
    'NAME'          => 'PerlIO::via::Limit',
    'VERSION_FROM'  => 'lib/PerlIO/via/Limit.pm', # finds $VERSION
    'LICENSE'       => 'perl',
    'PREREQ_PM'     => {
        'Test::More'        => '0.32',
        'PerlIO::via'       => '0',
        'Exception::Class'  => '0',
        'Class::Data::Inheritable' => '0',
    },
);
