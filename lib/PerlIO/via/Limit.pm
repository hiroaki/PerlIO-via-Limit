package PerlIO::via::Limit;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.02';

use Exception::Class ('PerlIO::via::Limit::Exception');

my $max_length  = undef;
my $sensitive   = undef;

sub import {
    my ($class, %params) = @_;
    $class->$_( $params{$_} ) for keys %params;
}

sub length {
    my $class = shift;
    return @_ ? $max_length = shift : $max_length;
}

sub sensitive {
    my $class = shift;
    return @_ ? $sensitive = shift : $sensitive;
}

sub PUSHED {
    my ($class, $mode, $fh) = @_;
    return bless {current => 0, reached => 0}, $class;
}

sub FILL {
    my ($obj, $fh) = @_;

    if( $obj->{reached} ){
        if( $obj->sensitive ){
            PerlIO::via::Limit::Exception
            ->throw( error => "$fh is trying to read exceeding the limit." );
        }
        return undef;
    }

    my $pos = tell $fh;
    my $buf = <$fh>;

    if( defined $buf ){
        $obj->{current} += CORE::length $buf;
        $obj->_check(\$buf);
    }

    return $buf;
}

sub WRITE {
    my ($obj, $buf, $fh) = @_;
    return 0 if( $obj->{reached} or ! defined $buf );

    $obj->{current} += CORE::length $buf;
    $obj->_check(\$buf);

    print $fh $buf;

    if( $obj->{reached} ){
        if( $obj->sensitive ){
            PerlIO::via::Limit::Exception
            ->throw( error => "$fh is trying to write exceeding the limit." );
        }
    }

    return CORE::length $buf;
}

sub _check {
    my ($obj, $ref_buf) = @_;
    if( defined $max_length ){
        my $over = $obj->{current} - $max_length;
        if( 0 <= $over ){
            $obj->{reached} = 1;
            substr($$ref_buf, $over * -1, $over, q{});
            # another expression: 
            # $$ref_buf = substr( $$ref_buf, 0, CORE::length($$ref_buf) - $over );
        }
    }
}


1;
__END__

=head1 NAME

PerlIO::via::Limit - PerlIO layer for length restrictions

=head1 SYNOPSIS

    use PerlIO::via::Limit;
    PerlIO::via::Limit->length(20);
    # - or -
    use PerlIO::via::Limit length => 20;

    # reading
    open( my $fh, "<:via(Limit)", $file );

    # writing
    open( my $fh, ">:via(Limit)", $file );

=head1 DESCRIPTION

PerlIO::via::Limit implements a PerlIO layer that restricts length of stream.

=head1 CLASS METHODS

=head2 length

Limit length of stream. Default is undef that means unlimited.

=head2 sensitive

If set true value, an exception will be occurred when stream reaches limit of length.
Default is false.

    use PerlIO::via::Limit sensitive => 1;

    open( my $in, "<:via(Limit)", $file ) or die;
    eval {
        while( <$in> ){
            # do something...
        }
    };if( $@ ){
        # "$in is trying to read exceeding the limit."
        warn "$@";
    }
    close $in or die;

Note that the $@ is a Exception::Class object.

=head1 BUGS

When the exception is thrown by sensitive option,
the buffer for reading does not be filled.

=head1 SEE ALSO

L<PerlIO::via>

L<Exception::Class>

=head1 REPOSITORY

PerlIO::via::Limit is hosted on github L<https://github.com/hiroaki/PerlIO-via-Limit>

=head1 AUTHOR

WATANABE Hiroaki E<lt>hwat@cpan.orgE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
