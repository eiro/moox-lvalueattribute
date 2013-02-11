package MooX::LvalueAttribute;
use strictures 1;

use Moo ();
use Moo::Role ();

sub import {
    my $class = shift;
    my $target = caller;

    require Object::ID;
    eval qq{ package $target;
             Object::ID->import(); 1;
           }
      or die
        "Error while trying to use Object::ID. error was: $@";

    unless ($Moo::MAKERS{$target} && $Moo::MAKERS{$target}{is_class}) {
        die "MooX::LvalueAttribute can only be used on Moo classes.";
    }

    Moo::Role->apply_roles_to_object(
      Moo->_accessor_maker_for($target),
      'Method::Generate::Accessor::Role::LvalueAttribute',
    );

}

1;
