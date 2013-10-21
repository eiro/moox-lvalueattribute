use strictures 1;
use Test::More;

use Devel::Hide qw(Class::XSAccessor);

{
    package MyRole;
    use Moo::Role;
    use MooX::LvalueAttribute;

    has three => (
                  is => 'rw',
                  lvalue => 1,
                 );

    has two => (
                is => 'rw',
                lvalue => 1,
               );

}

{
    package MooLvalue;
    use Moo;

    with ('MyRole');


    has four => (
                  is => 'rw',
                  lvalue => 1,
                 );

}

{
    package MooNoLvalue;
    use Moo;

    has two => (
                is => 'rw',
                lvalue => 1,
               );

    has four => (
                is => 'rw',
                lvalue => 1,
               );

}


my $lvalue = MooLvalue->new(one => 5, two => 6, three => 3);
is $lvalue->two, 6, "normal getter works";
$lvalue->two(43);
is $lvalue->two, 43, "normal setter still works";

$lvalue->two = 42;
is $lvalue->two, 42, "lvalue set works, defined in a role";

$lvalue->three = 3;
is $lvalue->three, 3, "lvalue set works for a second attribute";

eval { $lvalue->four = 42 };
like $@, qr/Can't modify non-lvalue subroutine/, "this attr has no lvalue";

my $lvalue2 = MooLvalue->new(two => 7);
is $lvalue2->two, 7, "different instances have different values";

my $lvalue3 = MooNoLvalue->new(two => 7, four => 8);
eval { $lvalue3->two = 42 };
like $@, qr/Can't modify non-lvalue subroutine/, "a class without lvalue - first attribute";
eval { $lvalue3->four = 42 };
like $@, qr/Can't modify non-lvalue subroutine/, "a class without lvalue - second attribute";

my $val = MooLvalue->new( two => 'explicit value', four => 'welp' );
eval { my $f = sprintf('%s', $val->two) };
is $@, '', 'lvalue attr from role works in sprintf';
eval { my $f = sprintf('%s', $val->four) };
is $@, '', 'lvalue attr from class works in sprintf';

done_testing;
