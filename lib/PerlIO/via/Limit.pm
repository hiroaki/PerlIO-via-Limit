package PerlIO::via::Limit;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.01';

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
    return undef if( $obj->is_over_limit );

    my $buf = <$fh>;
    $obj->{current} += CORE::length $buf;
    $obj->_check(\$buf)
        if( defined $buf and defined $max_length );
    return $buf;
}

sub WRITE {
    my ($obj, $buf, $fh) = @_;
    return undef if( $obj->is_over_limit );

    $obj->{current} += CORE::length $buf;
    $obj->_check(\$buf)
        if( defined $buf and defined $max_length );
    print $fh $buf;
    return CORE::length $buf;
}

sub _check {
    my ($obj, $ref_buf) = @_;
    my $over = $obj->{current} - $max_length;
    if( 0 <= $over ){
        $obj->{reached} = 1;
        $obj->is_over_limit;
        $$ref_buf = substr( $$ref_buf, 0, CORE::length($$ref_buf) - $over );
    }
}

sub is_over_limit {
    my $obj = shift;
    unless( $obj->{reached} ){
        return 0;    
    }else{
        if( my $val = $obj->sensitive ){
            return $val->($obj) if( ref($val) eq 'CODE' );
            die $val;
        }
        return 1;
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

If it is set true value, then CORE::die when stream reaches limit of length.
The message thrown by CORE::die is the same value.

    # when set the true value as scalar
    my $message = "over the limit";
    PerlIO::via::Limit->sensitive($message);

    eval {
        read ...
    };if( $@ and $@ eq $message ){
        # it read over the limit
    }

This also accepts a reference to CODE, it will be called instead of CORE::die.

    PerlIO::via::Limit->sensitive(sub { warn "over the limit\n"; 1; });

Default is false.

=head1 AUTHOR

WATANABE Hiroaki E<lt>hwat@mac.comE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<PerlIO::via>

=cut
