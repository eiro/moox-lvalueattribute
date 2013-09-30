use strictures 1;
use Test::More;

eval {
    package MooLvalueBroken;
    use Moo;
    use MooX::LvalueAttribute;

    has one => (
                is => 'ro',
                lvalue => 1,
               );
};

like $@, qr/lvalue was set but no accessor nor reader/, "can't set an lvalue on a ro attribute";

{
    package MooLvalue;
    use Moo;
    use MooX::LvalueAttribute;

    has two => (
                is => 'rw',
                lvalue => 1,
               );

    has three => (
                is => 'rw',
                lvalue => 1,
                isa => sub { die "not an integer" unless $_[0] =~ /^[0-9]+$/ },
               );

    has four => (
                is => 'rw',
               );

    has five => (
                is => 'rw',
                lvalue => 1,
                coerce => sub { $_[0] + 10 },
                );

    1;
}

my $lvalue = MooLvalue->new(one => 5, two => 6);
is $lvalue->two, 6, "normal getter works";
$lvalue->two(43);
is $lvalue->two, 43, "normal setter still works";

$lvalue->two = 42;
is $lvalue->two, 42, "lvalue set works";
is $lvalue->_lv_two(), 42, "underlying getter works";

$lvalue->three = 3;
is $lvalue->three, 3, "lvalue set works for a second attribute";
is $lvalue->_lv_three(), 3, "underlying getter works for a second attribute";

eval { $lvalue->four = 4; };
like $@, qr/Can't modify non-lvalue subroutine|Modification of a read-only value attempted/, "an attribute without lvalue";

my $lvalue2 = MooLvalue->new(two => 7);
is $lvalue2->two, 7, "different instances have different values";

my $lvalue3 = MooLvalue->new(two => 'foo');
is $lvalue3->two, 'foo', "not numerical values getter works";
$lvalue3->two = 'bar';
is $lvalue3->two, 'bar', "not numerical values setter works";

eval { $lvalue->three = "string" };
like $@, qr/not an integer/, 'isa checks applied';

my $ref = \($lvalue->three);
$$ref = 5;
is $lvalue->three, 5, 'set by ref works';
is $$ref, 5, 'ref updated';

eval { $$ref = 'string' };
like $@, qr/not an integer/, 'isa checks applied via ref';
is $$ref, 5, 'ref not updated after failed isa';

$lvalue->three = 6;
is $$ref, 6, 'ref updated with attribute';

my $write_return = $lvalue->five = 1;
is $write_return, 11, 'return value of lvalue is coerced value';

done_testing;
