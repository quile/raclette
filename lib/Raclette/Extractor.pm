package Raclette::Extractor;

use strict;
use warnings;
use utf8;


# TODO: more to come
our $_COMPOSERS = {
	"medtner"      => "Medtner, Nikolai",
    "mozart"       => "Mozart, Wolfgang Amadeus",
    "w. a. mozart" => "Mozart, Wolfgang Amadeus",
    "w.a. mozart"  => "Mozart, Wolfgang Amadeus",
    "bach"         => "Bach, Johann Sebastian",
    "j.s. bach"    => "Bach, Johann Sebastian",
    "j. s. bach"   => "Bach, Johann Sebastian",
    "haydn"        => "Haydn, Franz Joseph",
    "j. haydn"     => "Haydn, Franz Joseph",
    "beethoven"    => "Beethoven, Ludwig van",
    "chopin"       => "Chopin, Frédéric",
    "liszt"        => "Liszt, Franz",
    "mendelssohn"  => "Mendelssohn, Felix",
    "zelenka"      => "Zelenka, Jan Dismas",
    "bartok"       => "Béla Bartók",
    "bartók"       => "Béla Bartók",
    "kodaly"       => "Zoltán Kodály",
    "kodály"       => "Zoltán Kodály",
    "schumann"     => "Robert Schumann",
    "schubert"     => "Franz Schubert",
    "brahms"       => "Johannes Brahms",
    "grieg"        => "Edvard Grieg",
    "prokofiev"    => "Sergei Prokofiev",
    "rachmaninov"  => "Sergei Rachmaninov",
    "rachmaninoff" => "Sergei Rachmaninov",
    "rameau"       => "Jean-Philippe Rameau",
    "scarlatti"    => "Domenico Scarlatti",
    "tchaikovsky"  => "Pyotr Ilich Tchaikovsky",
    "weber"        => "Carl Maria von Weber",
    "borodin"      => "Alexander Borodin",
    "debussy"      => "Claude Debussy",
    "balakirev"    => "Milii Balakirev",
    "stravinsky"   => "Igor Stravinsky",
    "scriabin"     => "Aleksandr Scriabin",
    "kabalevsky"   => "Dmitri Kabalevsky",
};

sub new {
    my ($class, $json) = @_;
    my $self = {
        _json => $json,
    };
    return bless $self, $class;
}

sub extractSplits {
    my ($self) = @_;
    my $json = $self->{_json};

    my $desc = $json->{description};

    my $splits = [];
    my $track = 1;

    #TODO: provide more standard extractors
    while ($desc =~ m/^(\s*(\d+[:;][\d:;]+)\s*-\s*(.+))$/mg) {
        my $source = $1;
        my $time = $2;
        next unless $time;
        my $title = $3;

        my ($hours, $minutes, $seconds) = $self->extractTime($time);
        push @$splits, {
            start => ($hours * 3600) + ($minutes * 60) + $seconds,
            title => $title,
            track => $track,
            source => $source,
        };
        $track++;
    }

    if (@$splits > 0) {
        return $self->populateSplits($splits, $json->{duration});
    }

    # default:
    return [{
        start => 0,
        end => $json->{duration},
        title => $self->extractTitle(),
    }];
}

sub extractTitle {
    my ($self) = @_;
    my $json = $self->{_json};
    my $title = $json->{title};

    if ($title =~ m/^(.*?) - (.*)$/) {
        return $2;
    }
    return $title;
}

sub extractComments {
    my ($self) = @_;
    my $json = $self->{_json};
    return $json->{description};
}

sub extractYear {
    my ($self) = @_;

    my $title = $self->{_json}->{title};
    if ($title =~ m/\b(\d{4})\b/) {
        return $1;
    }

    my $comments = $self->{_json}->{description};

    if ($comments =~ m/composed:? (.*?)(\d{4})/i
     || $comments =~ m/written:? (.*?)(\d{4})/i
     || $comments =~ m/published:? (.*?)(\d{4})/i
     || $comments =~ m/first performed:? (.*?)(\d{4})/i
     || $comments =~ m/dated:? (.*?)(\d{4})/i) {
        return $2;
    }

    # look it up on wikipedia?
    return undef;
}

sub extractComposer {
    my ($self) = @_;

    my $title = $self->{_json}->{title};

    if ($title =~ m/(.*?)\s*[:-](.*)/) {
        return $self->normaliseComposer($1);
    }
    return undef;
}

sub extractPerformers {
    return [];
}

sub extractAlbum {
    return [];
}

sub populateSplits {
    my ($self, $splits, $duration) = @_;

    for (my $i = 0; $i < $#$splits; $i++) {
        $splits->[$i]->{end} = $splits->[$i+1]->{start};
    }
    $splits->[$#$splits]->{end} = $duration;

    if (scalar @$splits > 1) {
        for (my $i = 0; $i <= $#$splits; $i++) {
            $splits->[$i]->{track} ||= ($i+1);
        }
    }
    return $splits;
}

# TODO: build a proper model for this, because it's more
# complicated than name-fiddling.
sub normaliseComposer {
    my ($self, $composer) = @_;

    if (my $c = $_COMPOSERS->{lc($composer)}) {
        return $c;
    }

    # have to assume that a comma means it's in the right order.
    if ($composer =~ /\,/) {
        return $composer;
    }

    my @names = split(/\s+/, $composer);

    if (scalar @names == 2) {
        # reverse, so "Franz Liszt" becomes "Liszt, Franz"
        return $names[1] . ", " . $names[0];
    }

    my $first = shift @names;
    my $last = pop @names;

    return $last . ", ". join(" ", $first, @names);
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
