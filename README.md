# MooX::LvalueAttribute

Lvalue attributes support for Moo, the light Perl object system.

First we had the old school perl (the convenient but fragile)

    $$self{x} += 2

Then we had the Moo way (robust but boring to read and write)

    $self->x( $self->x + 2 )

But still we were frustated because [perl6](https://perl6.org/) and
[ruby](http://ruby-lang.org/) does it better.
Now we have `MooX::LvalueAttribute` (convenient and robust)

    $self->x += 2

Of course it works with all the operators including (re)affectation.

    $self->x   = 2;
    $self->y //= 10;

Learn about `:lvalue` from the
[subroutines section of the perl documentation](http://perldoc.perl.org/perlsub.html#Lvalue-subroutines).

Learn about `MooX::LvalueAttribute` from the
[MooX::LvalueAttribute CPAN page](https://metacpan.org/pod/MooX::LvalueAttribute)

Learn about `MooX::LvalueAttribute` from the
[Moo CPAN page](https://metacpan.org/pod/Moo)

don't miss our [CONTRIBUTING.md](CONTRIBUTING) file to be a part of the awesomeness.
