package Raclette::Extractor::ChopinInstitute;

use strict;
use warnings;
use utf8;

use Raclette::Utilities;

use base qw(Raclette::Extractor);

sub extractTitle {
    my ($self) = @_;
    my $title = $self->{_json}->{title};
    $title =~ m/(.*?)\s*\u2013\s*(.*) \(\d{4}\)?/;
    return $2 || $self->SUPER::extractTitle();
}

sub extractComposer {
    my ($self) = @_;
    return "Chopin, Frédéric";
}

sub extractPerformers {
    my ($self) = @_;
    my $title = $self->{_json}->{title};
    $title =~ m/(.*?)\s*\u2013\s*(.*) \(\d{4}\)?/;
    return [ $1 ];
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
