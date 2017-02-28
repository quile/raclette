package Raclette::Extractor::Klaviermusik;

use strict;
use warnings;

use base qw(Raclette::Extractor);

use Raclette::Utilities;

sub extractTitle {
    my ($self) = @_;
    my $title = $self->{_json}->{title};
    $title =~ m/(.*?): (.*?) \| (.*)$/;
    return $2 || $self->SUPER::extractTitle();
}

sub extractComposer {
    my ($self) = @_;
    my $title = $self->{_json}->{title};
    $title =~ m/(.*?): (.*?) \| (.*)$/;
    return $self->normaliseComposer($1 || $self->SUPER::extractComposer());
}

sub extractPerformers {
    my ($self) = @_;
    my $title = $self->{_json}->{title};
    $title =~ m/(.*?): (.*?) \| (.*)$/;
	return [$3];
}

sub extractSplits {
    my ($self) = @_;

    my $splits = [];

    my $json = $self->{_json};
    my $description = $json->{description};

    while ($description =~ /^(\d+[:;][\d:;]+)\s+(.+?)$/img) {
        my $name = $2;
        my $time = $1;
        next unless $time && $time =~ /[:;]/;
        my ($hours, $minutes, $seconds) = $self->extractTime($time);

        my $split = {
            start => $hours * 3600 + $minutes * 60 + $seconds,
            title => $name,
            source => $1,
        };
        push @$splits, $split;
    }

    return $self->populateSplits($splits, $json->{duration}) if scalar @$splits;
    return $self->SUPER::extractSplits();
}

1;
