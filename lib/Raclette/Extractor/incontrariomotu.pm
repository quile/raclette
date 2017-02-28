package Raclette::Extractor::incontrariomotu;

use strict;
use warnings;
use utf8;

use Raclette::Utilities;

use base qw(Raclette::Extractor);

sub extractTitle {
    my ($self) = @_;
    my $title = $self->{_json}->{title};
    $title =~ m/(.*?) - (.*) - (\((c. )?\d{4}\))?/;
    my $work = $2;
    $work =~ s/op.(\d+)n°(\d+)/Op. $1, $2/g;
    $work =~ s/op.(\d+)/Op. $1/g;
    $work =~ s/n°/No. /ig;
    return Raclette::Utilities::titleCase($work) || $self->SUPER::extractTitle();
}

sub extractComposer {
    my ($self) = @_;
    my $title = $self->{_json}->{title};
    $title =~ m/(.*?) - (.*) \(\d{4}\)/;
    return $self->normaliseComposer($1 || $self->SUPER::extractComposer());
}

sub extractPerformers {
    my ($self) = @_;
    my $description = $self->{_json}->{description};

    $DB::single = 1;
    my @bits = split(/^$/m, $description);
    my $performerBit = pop @bits;

    my @lines = split(/[\r\n]+/, $performerBit);
    shift @lines;

    if (scalar @lines > 1) {
        pop @lines;
        return \@lines;
    }
    return undef;
}

sub extractSplits {
    my ($self) = @_;

    my $splits = [];

    my $json = $self->{_json};
    my $description = $json->{description};

    while ($description =~ /^((n?°?([\divx]*)[\.,:]? ?(.*?))\(?(\d+[:;][\d:;]+)\)?)/igm) {
        my $movement = $2;
        my $roman = $3;
        my $tempo = $4;
        my $time = $5;
        next unless $time;

        my ($hours, $minutes, $seconds) = $self->extractTime($time);

        my $split = {
            start => $hours * 3600 + $minutes * 60 + $seconds,
            title => $tempo,
            track => Raclette::Utilities::arabic($roman) || undef,
            source => $1,
        };
        push @$splits, $split;
    }

    return $self->populateSplits($splits, $json->{duration}) if scalar @$splits;
    return $self->SUPER::extractSplits();
}

1;
