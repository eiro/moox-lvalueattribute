package MooX::LvalueAttribute;
use strictures 1;

# ABSTRACT: Provides Lvalue accessors to Moo class attributes

require Moo;
require Moo::Role;

our %INJECTED_IN;
our %OVERRIDEN;

sub import {
    my $class = shift;
    my $target = caller;

    if ($Moo::Role::INFO{$target} && $Moo::Role::INFO{$target}{is_role}) {
        # We are loaded from a Moo::Role
        if (! $OVERRIDEN{$target} ) {
            # We don't know yet in which class the role will be consumed, so we
            # have to work around that, and defer the injection
    
            my $old_accessor_maker = Moo->can('_accessor_maker_for');
    
            my $new_accessor_maker_for = sub {
                my ($class, $role_target) = @_;
                my $maker = $old_accessor_maker->(@_);
                $role_target->can('__lvalue_attr_mode')
                  && $role_target->__lvalue_attr_mode
                  && ! $INJECTED_IN{$role_target}
                    or return $maker;
                Moo::Role->apply_roles_to_object(
                    $maker,
                    'Method::Generate::Accessor::Role::LvalueAttribute',
                );
                $INJECTED_IN{$role_target} = 1;
                return $maker;
            };
    
            no strict 'refs';
            no warnings 'redefine';
            *{"${target}::__lvalue_attr_mode"} = sub { 1 }; 
            *Moo::_accessor_maker_for = $new_accessor_maker_for;
            $OVERRIDEN{$target} = 1
        }
    } elsif ($Moo::MAKERS{$target} && $Moo::MAKERS{$target}{is_class}) {
        # We are loaded from a Moo class
        if ( !$INJECTED_IN{$target} ) {
            Moo::Role->apply_roles_to_object(
              Moo->_accessor_maker_for($target),
              'Method::Generate::Accessor::Role::LvalueAttribute',
            );
            $INJECTED_IN{$target} = 1;        
        }
    } else {
        die "MooX::LvalueAttribute can only be used in Moo classes or Moo roles.";        
    }

}

=head1 SYNOPSIS

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

=cut

=head1 DESCRIPTION

B<WARNING>: this module is in its early stage, its API may change.

This modules provides Lvalue accessors to your Moo attributes. It won't break
Moo's encapsulation, and will properly call any accessor method modifiers,
triggers, builders and default values creation.

It means that instead of writing:

  $object->name("Foo");

you can use:

  $object->name = "Foo"; 

=head1 ATTRIBUTE SPECIFICATION

To enable Lvalue access to your attribute, simply use C<MooX::LvalueAttribute>
in the class, and add:

  lvalue => 1,

in the attribute specification (see synopsis).

=head1 NOTE ON IMPLEMENTATION

The implementation doesn't use AUTOLOAD, nor TIESCALAR. Instead, it uses a
custom accessor and C<Variable::Magic>, which is faster than the tie mechanism.

=cut

1;
