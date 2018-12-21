package MooX::LvalueAttribute;

use strictures 1;

# ABSTRACT: Provides Lvalue accessors to Moo class attributes

require Moo;
require Moo::Role;

sub import {
    my $class = shift;
    my $target = caller;

    my $maker;
    if ($Moo::Role::INFO{$target} && $Moo::Role::INFO{$target}{is_role}) {
        $maker = $Moo::Role::INFO{$target}{accessor_maker} ||= do {
            require Method::Generate::Accessor;
            Method::Generate::Accessor->new
        };
    }
    elsif ($Moo::MAKERS{$target} && $Moo::MAKERS{$target}{is_class}) {
        $maker = Moo->_accessor_maker_for($target);
    }
    else {
        die "MooX::LvalueAttribute can only be used in Moo classes or Moo roles.";
    }

    if (!$maker->does('Method::Generate::Accessor::Role::LvalueAttribute')) {
        Moo::Role->apply_roles_to_object(
            $maker,
            'Method::Generate::Accessor::Role::LvalueAttribute',
        );
    }
}

=head1 SYNOPSIS

=head2 From a Moo class

  package App;
  use Moo;
  use MooX::LvalueAttribute;
  
  has name => (
    is => 'rw',
    lvalue => 1,
  );

  # Elsewhere

  my $app = App->new(name => 'foo');
  $app->name = 'Bar';
  print $app->name;  # Bar

=head2 From a Moo role

  package MyRole;
  use Moo::Role;
  use MooX::LvalueAttribute;

  has name => (
    is => 'rw',
    lvalue => 1,
  );

  package App;
  use Moo;
  with('MyRole');

  # Elsewhere

  my $app = App->new(name => 'foo');
  $app->name = 'Bar';
  print $app->name;  # Bar

=head1 DESCRIPTION

This modules provides Lvalue accessors to your Moo attributes. It won't break
Moo's encapsulation, and will properly call any accessor method modifiers,
triggers, builders and default values creation. It can be used from a Moo class
or role.

It means that instead of writing:

  $object->name("Foo");

you can use:

  $object->name = "Foo"; 

=head1 ATTRIBUTE SPECIFICATION

To enable Lvalue access to your attribute, simply use C<MooX::LvalueAttribute>
in the class or role, and add:

  lvalue => 1,

in the attribute specification (see synopsis).

=head1 NOTE ON IMPLEMENTATION

The implementation doesn't use AUTOLOAD, nor TIESCALAR. Instead, it uses a
custom accessor and C<Variable::Magic>, which is faster and cheaper than the
tie / AUTOLOAD mechanisms.

=head1 CONTIBUTORS

This module was writen and originaly maintained by Damien "dams" Krotkine.
Contributors are

    Damien "dams" Krotkine.
    moznion
    Graham Knop
    Marc Chantreux
    Nicolas R

=cut

1;
