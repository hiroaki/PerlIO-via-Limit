use strict;
use Test::More tests => 20;
#use Test::More qw/no_plan/;

use PerlIO::via::Limit;
use Exception::Class;

my $file = "t/20_read_file.txt";
my $read;
my $s200 = qq{Perl officially stands for Practical Extraction and Report Language, except when it doesn't.\x0aPerl was originally a language optimized for scanning arbitrary text files, extracting information from tho}; #'

{
    my $contents = '';

    ok( open( $read, "<:via(Limit)", $file ), 'open for reading' );
    local $/ = undef;
    $contents = <$read>;
    ok( close $read, 'close ok' );
    is( length $contents, -s $file, 'unlimited, read all' );
}

{
    my $contents = '';
    PerlIO::via::Limit->length( (-s $file) * 2 );

    open( $read, "<:via(Limit)", $file ) or die;
    local $/ = undef;
    $contents = <$read>;
    close $read;
    is( length $contents, -s $file, 'read all less than limit' );
}

{
    my $contents = '';
    PerlIO::via::Limit->length(200);

    open( $read, "<:via(Limit)", $file ) or die;
    local $/ = undef;
    $contents = <$read>;
    close $read;
    is( length $contents, 200, 'limited 200' );
    is( $contents, $s200, 'contents restricted' );
}

{
    my $contents = '';
    PerlIO::via::Limit->length(200);

    open( $read, "<:via(Limit)", $file ) or die;
    while( <$read> ){
        $contents .= $_;
    }
    close $read;
    is( length $contents, 200, 'read limited step by step line' );
    is( $contents, $s200, 'contents has 200 length' );
}

{
    my $contents = '';
    PerlIO::via::Limit->length(200);
    open( $read, "<:via(Limit)", $file ) or die;

    my $total_size = 0;
    my $buf;
    while( my $size = read($read, $buf, 10) ){ # <--- less limit
        $total_size += $size;
        $contents   .= $buf;
    }
    close $read;
    is( length $contents, 200, 'read limited using CORE::read' );
    is( $contents, $s200, 'contents has 200 length' );
    is( $total_size, 200, 'CORE::read returns right value');
}

{
    my $contents = '';
    PerlIO::via::Limit->length(200);
    open( $read, "<:via(Limit)", $file ) or die;

    my $total_size = 0;
    my $buf;
    while( my $size = read($read, $buf, 200) ){ # <--- just limit
        $total_size += $size;
        $contents   .= $buf;
    }
    close $read;
    is( length $contents, 200, 'read limited using CORE::read' );
    is( $contents, $s200, 'contents has 200 length' );
    is( $total_size, 200, 'CORE::read returns right value');
}

{
    my $contents = '';
    PerlIO::via::Limit->length(200);
    open( $read, "<:via(Limit)", $file ) or die;

    my $total_size = 0;
    my $buf;
    while( my $size = read($read, $buf, 1024) ){ # <--- over limit
        $total_size += $size;
        $contents   .= $buf;
    }
    close $read;
    is( length $contents, 200, 'read limited using CORE::read' );
    is( $contents, $s200, 'contents has 200 length' );
    is( $total_size, 200, 'CORE::read returns right value');
}

{
    my $contents = '';
    PerlIO::via::Limit->length(10);
    PerlIO::via::Limit->sensitive(1);
    open( $read, "<:via(Limit)", $file ) or die;
    
    eval {
        while( my $line = <$read> ){
            $contents .= $line;
        }
    };
    my $exception = $@;

    close $read or die;

    ok( ref($exception), "exception is a reference" );

    ok( Exception::Class->caught('PerlIO::via::Limit::Exception'), 'caught PerlIO::via::Limit::Exception');

    TODO: {
        local $TODO = "How to do it?";
        is( length $contents, 10, 'caught but it has read restrict length');
    }
}

1;
__END__
