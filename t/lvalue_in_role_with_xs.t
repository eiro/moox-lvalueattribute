use strictures 1;
use Test::More;

use Method::Generate::Accessor;

$Method::Generate::Accessor::CAN_HAZ_XS
  or plan( skip_all => 'Need Class::XSAccessor to run these tests' );

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

my $lvalue2 = MooLvalue->new(two => 7);
is $lvalue2->two, 7, "different instances have different values";

done_testing;
