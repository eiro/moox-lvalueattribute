package MooX::LvalueAttribute;
use strictures 1;
use Variable::Magic qw(wizard cast getdata);

# ABSTRACT: Provides Lvalue accessors to Moo class attributes

use Class::Method::Modifiers qw(install_modifier);

sub import {
    my $class = shift;
    my $target = caller;

    die "MooX::LvalueAttribute can only be used in Moo classes or Moo roles."
      if !$target->can('has');

    install_modifier($target, 'after', 'has', sub {
      my @attrs = ref $_[0] ? @{ +shift } : shift;
      my %spec = @_;
      return unless $spec{lvalue};
      for my $attr (@attrs) {
        my $is = $spec{is};
        my $reader = $spec{reader} || $spec{accessor} ||
          $is ne 'bare' ? $attr
          : die "lvalue was set but no accessor nor reader";
        my $writer = $spec{writer} || $spec{accessor} ||
            $spec{is} eq 'rw'   ? $attr
          : $spec{is} eq 'rwp'  ? "_set_$attr"
          : die "lvalue was set but no accessor nor writer";

        my $wiz;
        $wiz = wizard(
          data => sub { $_[1] },
          set  => sub { getdata(${$_[0]}, $wiz)->$writer(${$_[0]}) },
        );
        install_modifier($target, 'around', $reader, sub :lvalue {
          my $orig = shift;
          my $self = shift;
          my $val = $self->$orig(@_);
          cast $val, $wiz, $self;
          $val;
        });
      }
    });
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

=cut

1;
