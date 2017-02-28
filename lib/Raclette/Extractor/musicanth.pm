package Raclette::Extractor::musicanth;

use strict;
use warnings;

use Raclette::Utilities;

use base qw(Raclette::Extractor);

sub extractTitle {
    my ($self) = @_;
    my $title = $self->{_json}->{title};
    $title =~ m/(.*?)\s*-\s*(.*) \(\d{4}\)?/;
    return $2 || $self->SUPER::extractTitle();
}

sub extractComposer {
     my ($self) = @_;
    my $title = $self->{_json}->{title};
    $title =~ m/(.*?)\s*-\s*(.*) \(\d{4}\)?/;
    return $self->normaliseComposer($1 || $self->SUPER::extractComposer());
}

sub extractPerformers {
    my ($self) = @_;
    my $description = $self->{_json}->{description};

    $description =~ m/Performers?: ([^\$]+)/;
    if ($1) {
        my @performers = split(", ", $1);
        return \@performers;
    }
    return []
}

sub extractSplits {
    my ($self) = @_;

    my $splits = [];

    my $json = $self->{_json};
    my $description = $json->{description};

    while ($description =~ /(([ivx]+)\. (.*?)\s*-?\s+[\(\[]?(\d+[:;][\d:;]+)[\)\]]?)\s+/ig) {
        my $movement = $3;
        my $roman = $2;
        my $time = $4;

        next unless $time;

        my ($hours, $minutes, $seconds) = $self->extractTime($time);

        my $split = {
            start => $hours * 3600 + $minutes * 60 + $seconds,
            title => $movement,
            track => Raclette::Utilities::arabic($roman),
            source => $1,
        };
        push @$splits, $split;
    }

    return $self->populateSplits($splits, $json->{duration}) if scalar @$splits;
    return $self->SUPER::extractSplits();
}

1;
