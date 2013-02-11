package Method::Generate::Accessor::Role::LvalueAttribute;

use strictures 1;
use Moo::Role;
use Variable::Magic qw(wizard cast);

my %_lvalues;

around generate_method => sub {
    my $orig = shift;
    my $self = shift;
    # would like a better way to disable XS
    
    my ($into, $name, $spec, $quote_opts) = @_;

    if ($spec->{lvalue}) {

        my $is = $spec->{is};
        if ($is eq 'rw') {
            $spec->{accessor} = $name unless exists $spec->{accessor}
              or ( $spec->{reader} and $spec->{writer} );
        } elsif ($is eq 'rwp') {
            $spec->{writer} = "_set_${name}" unless exists $spec->{writer};
        }

        exists $spec->{writer} || exists $spec->{accessor}
          or die "lvalue was set but no accessor nor reader, and attribute i not rw";
        foreach( qw(writer accessor) ) {
            my $t = $spec->{$_}
              or next;
            $spec->{'lv_' . $_} = $t;
            $spec->{$_} = '_lv_' . $t;
        }
    }

    my $methods = $self->$orig(@_);

    foreach ( qw(writer accessor) ) {
        my $lv_name = $spec->{'lv_' . $_}
          or next;
        my $name = $spec->{$_};
        no strict 'refs';
        my $sub = sub : lvalue {
            my $self = shift;
            my $object_id = $self->object_id;
            if (! exists $_lvalues{$object_id}) {
                my $wiz = wizard(
                 set  => sub { $self->$name(${$_[0]}) },
                 get => sub { ${$_[0]} = $self->$name() },
                );
                cast $_lvalues{$object_id}, $wiz;
            }
            @_ and $self->$name(@_);
            $_lvalues{$object_id};
        };
        $methods->{$lv_name} = $sub;
        *{"${into}::${lv_name}"} = $sub;
    }
};

1;
