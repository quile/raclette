package Raclette::YTDL;

use strict;
use warnings;

sub new {
    my ($class, $input, $output) = @_;

    my $self = {
        _input => $input,
        _output => $output,
    };

    return bless $self, $class;
}

sub init {
    my ($self) = @_;

    # ?
    return $self;
}

sub execute {
    my ($self) = @_;

    $self->setUniqueRunId($self->generateNextRunId());

    my $options = [
        "--write-info-json",
        "--extract-audio",
        "--audio-format=m4a",
        "--audio-quality=0",
        "--write-thumbnail",
        "--output",
        '"' . $self->outputString() . '"',
        $self->{_input},
    ];

    my $command = "youtube-dl ".join(" ", @$options);

    my $output = `$command`;

    return {
        "location" => $self->fullPathToOutput(),
        "output"   => $output,
    };
}

sub fullPathToOutput {
    my ($self) = @_;

    my $path = [];
    if ($self->{_output}) {
        push @$path, $self->{_output};
    } else {
        push @$path, ".";
    }
    push @$path, $self->{_uniqueRunId} if $self->{_uniqueRunId};
    return join(" ", @$path);
}

sub setUniqueRunId {
    my ($self, $value) = @_;
    $self->{_uniqueRunId} = $value;
}

sub generateNextRunId {
    my ($self) = @_;
    return $self->nextRunForDirectory($self->{_output});
}

sub outputString {
    my ($self) = @_;

    my $output = "";
    
    if ($self->{_output}) {
        $output .= $self->{_output}."/";
    }

    my $nextRun = $self->{_uniqueRunId};
    if (defined $nextRun) {
        $output .= $nextRun."/";
    }

    $output .= "%(autonumber)s/";
    $output .= "audio.%(ext)s";
    print STDERR "Using $output for output location\n";
    return $output;
}

sub nextRunForDirectory {
    my ($self, $dir) = @_;

    $dir ||= ".";
    my $start = 0;
    my $exists = 0;

    do {
        $exists = (-d "$dir/$start");
        if ($exists) {
            $start++;
        }
    } while ($exists);

    print STDERR "Next run is $start\n";
    return sprintf("%d", $start);
}

1;
