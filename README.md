# NAME

PerlIO::via::Limit - PerlIO layer for length restrictions

# SYNOPSIS

    use PerlIO::via::Limit;
    PerlIO::via::Limit->length(256);
    # - or -
    use PerlIO::via::Limit length => 256;

    # reading
    open( my $fh, "<:via(Limit)", $file );

    # writing
    open( my $fh, ">:via(Limit)", $file );

    # If you want to use various limits simultaneously
    my $limit256 = PerlIO::via::Limit->create(256);
    my $limit512 = PerlIO::via::Limit->create(512);
    open( my $fh256, "<:via($limit256)", $hoge );
    open( my $fh512, ">:via($limit512)", $fuga );

# DESCRIPTION

PerlIO::via::Limit implements a PerlIO layer that restricts length of stream.

There is an important constraint, 
it is able to specify only one limit value within application 
because the 'length' is a class data.

The following example does not work as expected:

    PerlIO::via::Limit->length(256);
    open( my $fh1, "<:via(Limit)", $file1 );

    PerlIO::via::Limit->length(512);
    open( my $fh2, "<:via(Limit)", $file2 );

    local $/ = undef;
    my $data1 = <$fh1>; 
    my $data2 = <$fh2>; 

    CORE::length($data1); # is not 256 but 512
    CORE::length($data2); # is also 512

Therefore, it is necessary to divide namespace,
in order to use two or more limit values simultaneously.

    package Foo;
    use base PerlIO::via::Limit;
    
    package main;
    PerlIO::via::Limit->length(256);
    Foo->length(512);

    open( my $fh1, "<:via(Limit)", $file1 );
    open( my $fh2, "<:via(Foo)", $file2 );

    local $/ = undef;
    my $data1 = <$fh1>; 
    my $data2 = <$fh2>; 

    CORE::length($data1); # is 256
    CORE::length($data2); # is 512

Actually you do not have to code like the above,
instead, the create() method supports it by simple interface.

    my $limit256 = PerlIO::via::Limit->create(256);
    my $limit512 = PerlIO::via::Limit->create(512);

    open( my $fh1, "<:via($limit256)", $file1 );
    open( my $fh2, "<:via($limit100)", $file2 );

# CLASS METHODS

## create

Create an anonymous class that is inheritable [PerlIO::via::Limit](https://metacpan.org/pod/PerlIO::via::Limit).

You do not have to care about the class, only pass ':via' the returned value as it is.

It accepts an optional parameter for 'length' available.

    my $limit = PerlIO::via::Limit->create(512);
    open( my $fh, ">:via($limit)", $file );

Also it can call 'length' and 'sensitive' class methods.

    my $limit = PerlIO::via::Limit->create;
    $limit->length(256);
    $limit->sensitive(0);
    open( my $fh, ">:via($limit)", $file );

## length

Limit length of stream.
Default is undef that means unlimited.

## sensitive

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

Note that the $@ is an Exception::Class object.

# BUGS

When the exception is thrown by sensitive option,
the buffer for reading does not be filled.

# REPOSITORY

PerlIO::via::Limit is hosted on github [https://github.com/hiroaki/PerlIO-via-Limit](https://github.com/hiroaki/PerlIO-via-Limit)

# SEE ALSO

[PerlIO::via](https://metacpan.org/pod/PerlIO::via)

[Exception::Class](https://metacpan.org/pod/Exception::Class)

# AUTHOR

WATANABE Hiroaki <hwat@cpan.org>

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
