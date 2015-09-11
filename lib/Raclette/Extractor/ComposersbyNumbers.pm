package Raclette::Extractor::ComposersbyNumbers;

use strict;
use warnings;

use base qw(Raclette::Extractor);

use Raclette::Utilities;

sub extractTitle {
    my ($self) = @_;
    my $title = $self->{_json}->{title};
    $title =~ m/(.*?) - (.*?) - (.*)/;
    return "$3, $2" || $self->SUPER::extractTitle();
}

sub extractComposer {
    my ($self) = @_;
    my $title = $self->{_json}->{title};
    $title =~ m/(.*?)\s+-\s+(.*?)\s+-\s+(.*)/;
    return $self->normaliseComposer($1 || $self->SUPER::extractComposer());
}

sub extractPerformers {
    my ($self) = @_;
    my $description = $self->{_json}->{description};

    $description =~ m/Performers?: ([^\$]+)/;
    if ($1) {
        my @performers = split(", ", $1);
        foreach my $performer (@performers) {
            $performer =~ s/\.$//;
        }
        return \@performers;
    }
    return []
}

sub extractSplits {
    my ($self) = @_;

    my $splits = [];

    my $json = $self->{_json};
    my $description = $json->{description};

    while ($description =~ /((\d+)\. (.*?)\s*-?\s*\(?(\d+[:;][\d:;]+)\)?)\s+/ig) {
        my $track = $2;
        my $tempo = $3;
        my $time  = $4;
        next unless $time && $time =~ /[:;]/;
        my ($hours, $minutes, $seconds) = $self->extractTime($time);

        my $split = {
            start => $hours * 3600 + $minutes * 60 + $seconds,
            title => $tempo,
            track => $track,
            source => $1,
        };
        push @$splits, $split;
    }

    if (scalar @$splits == 0) {
        # Hmmmm, might be a work with un-numbered movements, like an opera or
        # oratorio, so let's try that:

        my $track = 1;
        while ($description =~ /(- (.*?) \(?(\d+[:;][\d:;]+)\)?)\s+/ig) {
            my $title = $2;
            my $time = $3;
            next unless $time && $time =~ /[:;]/;
            my ($hours, $minutes, $seconds) = $self->extractTime($time);

            my $split = {
                start => $hours * 3600 + $minutes * 60 + $seconds,
                title => $title,
                track => $track,
                source => $1,
            };
            push @$splits, $split;
            $track++;
        }
    }

    return $self->populateSplits($splits, $json->{duration}) if scalar @$splits;
    return $self->SUPER::extractSplits();
}

sub extractTime {
    my ($self, $time) = @_;
    
    if ($time =~ m/^(\d+)[:;](\d+)$/) {
        return (0, $1, $2);
    }
    if ($time =~ m/^(\d+)[;:](\d+)[:;](\d+)$/) {
        return ($1, $2, $3);
    }
    return (0, 0, 0);
}

1;
