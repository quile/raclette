package Raclette::Extractor::AdrienSoto;

use strict;
use warnings;

use base qw(Raclette::Extractor);

sub extractTitle {
    my ($self) = @_;
    my $title = $self->{_json}->{title};
    $title =~ m/(.*?) : (.*) \((.*)\)$/;
    return $2 || $self->SUPER::extractTitle();
}

sub extractComposer {
    my ($self) = @_;
    my $title = $self->{_json}->{title};
    $title =~ m/^(.*?) : (.*) \((.*)\)$/;
    return $self->normaliseComposer($1 || $self->SUPER::extractComposer());
}

# our $_PERFORMER_KEYS = [qw(
    # Pianist
    # Violinist
    # Orchestra
    # Conductor
    # Ensemble
    # Horn
    # Flute
    # Clarinet
    # Oboe
    # Bassoon
    # Trumpet
    # Trombone
    # Harp
    # Harpsichord
    # Keyboard
    # Mandoline
    # Mandolin
    # Double.bass
    # Cor.anglais
    # Viola
    # Piano
    # Violin
    # Cello
    # Organ
# )];
# 

sub extractPerformers {
    my ($self) = @_;
    my $title = $self->{_json}->{title};
    $title =~ m/^(.*?) : (.*) \((.*)\)$/;
    return [$3] || $self->SUPER::extractPerformers();
}

# sub extractPerformers {
    # my ($self) = @_;
    # my $description = $self->{_json}->{description};
# 
    # $description =~ m/Performers?: ([^\$]+)/;
    # if ($1) {
        # my @performers = split(", ", $1);
        # return \@performers;
    # }
# 
    # my $performers = [];
    # foreach my $key (@$_PERFORMER_KEYS) {
        # my $re = "^$key: (.*)\$";
        # my $r = qr/$re/mi;
# 
        # while ($description =~ /$r/g) {
            # push @$performers, "$1, $key";
        # }
    # }
# 
    # return $performers;
# }

sub extractSplits {
    my ($self) = @_;

    my $splits = [];

    my $json = $self->{_json};
    my $description = $json->{description};

    # I. Allegro moderato 00:00
	$DB::single = 1;
    while ($description =~ /((([ivx]+)[\.,:] (.*?)) \(?(\d+[:;][\d:;]+)\)?)/igm) {
        my $movement = $1;
        my $roman = lc($3);
        my $tempo = $4;
        my $time = $5;
        next unless $time;

        my ($hours, $minutes, $seconds) = $self->extractTime($time);

        my $split = {
            start => $hours * 3600 + $minutes * 60 + $seconds,
            title => $tempo,
            track => $self->_romanToArabic($roman),
            source => $1,
        };
        push @$splits, $split;
    }

    return $self->populateSplits($splits, $json->{duration}) if scalar @$splits;
    return $self->SUPER::extractSplits();
}

sub _romanToArabic {
    my ($self, $roman) = @_;

    # brute force.  can't be bothered with anything else.
    $roman = lc($roman);
    return 1 if ($roman eq "i");
    return 2 if ($roman eq "ii");
    return 3 if ($roman eq "iii");
    return 4 if ($roman eq "iv");
    return 5 if ($roman eq "v");
    return 6 if ($roman eq "vi");
    return 7 if ($roman eq "vii");
    return 8 if ($roman eq "viii");
    return 9 if ($roman eq "ix");
    return 10 if ($roman eq "x");

    # can't be arsed going higher than 10
    return 0;
}

1;
