package Method::Generate::Accessor::Role::LvalueAttribute;

use strictures 1;

# ABSTRACT: Provides Lvalue accessors to Moo class attributes

use Moo::Role;
use Variable::Magic qw(wizard cast);
use Class::Method::Modifiers qw(install_modifier);
use Hash::Util::FieldHash::Compat qw(fieldhash);

after generate_method => sub {
    my $self = shift;
    my ($into, $name, $spec, $quote_opts) = @_;

    return if !$spec->{lvalue};

    my $reader = $spec->{reader} || $spec->{accessor}
        or die "lvalue was set but no accessor nor reader";
    my $writer = $spec->{writer} || $spec->{accessor}
        or die "lvalue was set but no accessor nor writer";

    my $read_code = $into->can($reader);
    my $write_code = $into->can($writer);

    my $wiz = wizard(
        data => sub { $_[1] },
        get  => sub { ${$_[0]} = $_[1]->$read_code; 1 },
        set  => sub { $_[1]->$write_code(${$_[0]}); 1 },
    );

    fieldhash my %cast;
    for my $method (grep defined, map $spec->{$_}, qw(writer accessor)) {
        install_modifier($into, 'around', $method, sub :lvalue {
            my $orig = shift;
            my $self = shift;
            my $val;
            $val = $self->$orig(@_)
                if @_;
            if (!exists $cast{$self}) {
                cast $cast{$self}, $wiz, $self;
            }
            $cast{$self};
        });
    }
};

1;
