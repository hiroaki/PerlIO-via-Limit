use strict;
use Test::More tests => 9;
#use Test::More qw/no_plan/;

use PerlIO::via::Limit;

my $file = "t/30_write_file.txt";
my $write;
my $contents = qq[Perl officially stands for Practical Extraction and Report Language, except when it doesn't.\x0aPerl was originally a language optimized for scanning arbitrary text files, extracting information from those text files, and printing reports based on that information. It quickly became a good language for many system management tasks. Over the years, Perl has grown into a general-purpose programming language. It's widely used for everything from quick "one-liners" to full-scale application development.\x0a];

{
    ok( open( $write, ">:raw:via(Limit)", $file ), 'open for writing' );
    ok( print( $write $contents ), 'prints' );
    ok( close $write, 'close ok');
    is( -s $file, CORE::length $contents, 'no limit');
}

{
    PerlIO::via::Limit->length(102);
    
    open( $write, ">:raw:via(Limit)", $file ) or die;
    print $write $contents;
    close $write or die;
    is( -s $file, 102, 'restrict length 102');
}

{
    PerlIO::via::Limit->length(10);
    PerlIO::via::Limit->sensitive(1);
    
    open( $write, ">:raw:via(Limit)", $file ) or die;
    eval {
        print $write "0123456";
        print $write "789A";
    };
    my $exception = $@;

    ok( $exception, 'sensitive option throws exception');

    close $write or die;

    ok( ref($exception), "exception is a reference" );

    ok( Exception::Class->caught('PerlIO::via::Limit::Exception'), 'caught PerlIO::via::Limit::Exception');

    is( -s $file, 10, 'caught but it has written restrict length');
}

1;
__END__
