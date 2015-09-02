package Raclette::Extractor;

use strict;
use warnings;
use utf8;


# TODO: more to come
our $_COMPOSERS = {
    "mozart"       => "Mozart, Wolfgang Amadeus",
    "w. a. mozart" => "Mozart, Wolfgang Amadeus",
    "bach"         => "Bach, Johann Sebastian",
    "haydn"        => "Haydn, Franz Joseph",
    "beethoven"    => "Beethoven, Ludwig van",
    "chopin"       => "Chopin, Frédéric",
    "liszt"        => "Liszt, Franz",
    "mendelssohn"  => "Mendelssohn, Felix",
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
    return [{
        start => 0,
        end => $json->{duration},
        title => $self->extractTitle(),
    }];
}

sub extractTitle {
    my ($self) = @_;
    my $json = $self->{_json};
    return $json->{title};
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

    if ($comments =~ m/composed in (\d{4})/
     || $comments =~ m/written in (\d{4})/) {
        return $1;
    }

    # look it up on wikipedia?
    return undef;
}

sub extractComposer {
    my ($self) = @_;
    
    my $title = $self->{_json}->{title};

    $DB::single = 1;
    if ($title =~ m/(.*?): (.*)/ || $title =~ m/(.*?) - (.*)/) {
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

1;
