package Raclette::Extractor::ComposersbyNumbers;

use strict;
use warnings;

use base qw(Raclette::Extractor);

sub extractTitle {
    my ($self) = @_;
    my $title = $self->{_json}->{title};
    $title =~ m/(.*?) - (.*?) - (.*)/;
    return "$3, $2" || $self->SUPER::extractTitle();
}

sub extractComposer {
     my ($self) = @_;
    my $title = $self->{_json}->{title};
    $title =~ m/(.*?) - (.*?) - (.*)/;
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

    while ($description =~ /((\d+)\. (.*?)\s*-?\s*\(?(\d+):(\d+)\)?)\s+/ig) {
        my $track = $2;
        my $tempo = $3;
        my $minutes = $4;
        my $seconds = $5;

        my $split = {
            start => $minutes * 60 + $seconds,
            title => _roman($track).". ".$tempo,
            track => $track,
            source => $1,
        };
        push @$splits, $split;
    }

    $DB::single = 1;
    return $self->populateSplits($splits, $json->{duration});
}

sub _roman {
    my ($num) = @_;

    return "I" if $num == 1;
    return "II" if $num == 2;
    return "III" if $num == 3;
    return "IV" if $num == 4;
    return "V" if $num == 5;
    return "VI" if $num == 6;
    return "VII" if $num == 7;
    return "VIII" if $num == 8;
    return "IX" if $num == 9;
    return "X" if $num == 10;
    return $num;
}

1;
