package Raclette::Extractor::MartinJones;

use strict;
use warnings;

use base qw(Raclette::Extractor);

use Raclette::Utilities;

sub extractTitle {
    my ($self) = @_;
    my $title = $self->{_json}->{title};
    $title =~ m/^([^:]+):/m;
    return $1 || $self->SUPER::extractTitle();
}

sub extractComposer {
    my ($self) = @_;
    my $desc = $self->{_json}->{description};
    $desc =~ m/^(.*) \x{b7} (.*)? \x{b7} (.*)?$/m;
    return $self->normaliseComposer($2 || $self->SUPER::extractComposer());
}

sub extractPerformers {
    my ($self) = @_;
    my $description = $self->{_json}->{description};

    my $desc = $self->{_json}->{description};
    $desc =~ m/^(.*) \x{b7} (.*)? \x{b7} (.*)?$/m;
    if ($3) {
        return [$3];
    }
    return []
}

sub extractSplits {
    my ($self) = @_;

    my $splits = [];

    my $json = $self->{_json};
    my $description = $json->{description};

    if ($description =~ m/^(([^:]+)?: ([IVX]+)\.? ?(.*) \x{b7} (.*)? \x{b7} (.*)?)$/m) {
        my $work = $2;
        my $track = $3 || undef;
        my $title = $4;
        
        push @$splits, {
            start => 0,
            title => $title,
            track => Raclette::Utilities::arabic($track),
            source => $1
        };
    }

    return $self->populateSplits($splits, $json->{duration}) if scalar @$splits;
    return $self->SUPER::extractSplits();
}

1;
