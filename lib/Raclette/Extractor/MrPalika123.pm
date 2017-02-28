package Raclette::Extractor::MrPalika123;

use strict;
use warnings;

use base qw(Raclette::Extractor);

sub extractTitle {
    my ($self) = @_;
    my $title = $self->{_json}->{title};
    $title =~ m/(.*?) - (.*) \((.+?)\)?/;
    return $2 || $self->SUPER::extractTitle();
}

sub extractComposer {
    my ($self) = @_;
    my $title = $self->{_json}->{title};
    $title =~ m/(.*?) - (.*) \((.+?)\)?/;
    return $self->normaliseComposer($1 || $self->SUPER::extractComposer());
}

sub extractPerformers {
    my ($self) = @_;
    my $title = $self->{_json}->{title};
    $title =~ m/(.*?) - (.*) \((.+?)\)?/;
	my $primary = $3;

    my $description = $self->{_json}->{description};
	my $performers = [];

	my @bits = split(/\n\n/, $description);
	if (scalar @bits > 1) {
		foreach my $p (split(/\n/, $bits[$#bits-1])) {
			push @$performers, $p;
		}
	}
	
	if ($primary && scalar @$performers == 0) {
		push @$performers, $primary;
	}

    return $performers;
}

sub extractSplits {
    my ($self) = @_;

    my $splits = [];

    my $json = $self->{_json};
    my $description = $json->{description};

	my $track = 1;

    # Seen these:
    # 00:00 Andante mesto - Allegro moderato
    while ($description =~ /^(\d+[:;][\d:;]+)\s+(.*)?$/igm) {
        my $time = $1;
		my $movement = $2;
        next unless $time;

        my ($hours, $minutes, $seconds) = $self->extractTime($time);

        my $split = {
            start => $hours * 3600 + $minutes * 60 + $seconds,
            title => $movement,
			track => $track++,
            source => $1,
        };
        push @$splits, $split;
    }

    return $self->populateSplits($splits, $json->{duration}) if scalar @$splits;
    return $self->SUPER::extractSplits();
}

1;
