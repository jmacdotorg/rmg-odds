package OddsConverter;

use Moose;
use Moose::Util::TypeConstraints;

use Readonly;
Readonly my $INFINITY => 'Inf.';

subtype 'ProbabilityNum',
    as 'Num',
    where { $_ >= 0 && $_ <= 1 },
    message { "The provided number, $_, is not between 0 and 1." };

# probability is a required constructor argument. Must be a valid value for P.
has 'probability' => (
    required => 1,
    isa => 'ProbabilityNum',
    is => 'ro',
);

# odds is stored as a number, and is allowed to be undef (in the case of P=0).
has 'odds' => (
    lazy => 1,
    builder => '_compute_odds',
    isa => 'Maybe[Num]',
    is => 'ro',
);

# decimal_odds and roi are stored as formatted strings, based on the computed odds.
has 'decimal_odds' => (
    lazy => 1,
    builder => '_build_decimal_odds',
    isa => 'Str',
    is => 'ro',
);

has 'roi' => (
    lazy => 1,
    builder => '_build_roi',
    isa => 'Str',
    is => 'ro',
);

sub _compute_odds {
    my $self = shift;

    my $p = $self->probability;
    if ( $p ) {
        my $odds = ( 1 - $p ) / $p;
        return $odds;
    }
    else {
        return;
    }
}

sub _build_decimal_odds {
    my $self = shift;

    if ( $self->probability ) {
        return sprintf( '%.2f', $self->odds + 1 );
    }
    else {
        return $INFINITY;
    }
}

sub _build_roi {
    my $self = shift;

    if ( $self->probability ) {
        return sprintf( '%.0f%%', $self->odds * 100 );
    } else {
        return $INFINITY;
    }
}

=head1 NAME

OddsConverter

=head1 SYNOPSIS

    my $oc = OddsConverter->new(probability => 0.5);
    print $oc->decimal_odds;    # '2.00' (always to 2 decimal places)
    print $oc->roi;             # '100%' (always whole numbers or 'Inf.')

=cut

1;
