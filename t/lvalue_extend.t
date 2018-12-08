use strictures 1;
use Test::More;

eval q{
  package MooLvalue;
  use Moo;
  use MooX::LvalueAttribute;

  has one => (
    is => 'rw',
    lvalue => 1,
  );
  $INC{'MooLvalue.pm'} = __FILE__;
};
is $@, '', 'define class with lvalue works';

eval q{
  package MooExtendLvalue;
  use Moo;
  extends 'MooLvalue';
  has '+one' => (
    required => 1,
  );
  $INC{'MooExtendLvalue.pm'} = __FILE__;
};
is $@, '', 'can extend lvalue attribute';

my $extendlvalue = MooExtendLvalue->new(one => 1);
eval { $extendlvalue->one = 5 };
is $@, '', 'extended attribute still lvalue';

eval q{
  package MooClass;
  use Moo;
  has 'one' => (
    is => 'rw',
    required => 1,
  );
  $INC{'MooClass.pm'} = __FILE__;
};
is $@, '', 'define normal class';

eval q{
  package MooClassAddLvalue;
  use Moo;
  use MooX::LvalueAttribute;
  extends 'MooClass';
  has '+one' => (
    lvalue => 1,
  );
  $INC{'MooClassAddLvalue.pm'} = __FILE__;
};
is $@, '', 'extend normal class, adding lvalue';

my $addlvalue = MooClassAddLvalue->new(one => 1);
eval { $addlvalue->one = 5 };
is $@, '', 'added lvalue works';

done_testing;
