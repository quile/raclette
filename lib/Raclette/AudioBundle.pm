package Raclette::AudioBundle;

use strict;
use warnings;

use JSON;

sub new {
    my ($class, $path) = @_;

    return bless {
        _path => $path,
    }, $class;
}

sub init {
    my ($self) = @_;

    my $json = $self->json();
    
    return $self;
}

sub audioFile {
    my ($self) = @_;
    return defined $self->{_audioFile} ?
            $self->{_audioFile} :
            $self->{_audioFile} = $self->hopefullyExists($self->{_path}."/audio.m4a")
                               || $self->hopefullyExists($self->{_path}."/audio.webm");
}

sub jsonFile {
    my ($self) = @_;
    return defined $self->{_jsonFile} ?
            $self->{_jsonFile} :
            $self->{_jsonFile} = $self->hopefullyExists($self->{_path}."/audio.info.json");
}

sub imageFile {
    my ($self) = @_;
    return defined $self->{_imageFile} ?
            $self->{_imageFile} :
            $self->{_imageFile} = $self->hopefullyExists($self->{_path}."/audio.jpg");
}

sub tagsFile {
	my ($self) = @_;
	return defined $self->{_tagsFile} ?
			$self->{_tagsFile} :
			$self->{_tagsFile} = $self->hopefullyExists($self->{_path}."/tags.json");
}

sub json {
    my ($self) = @_;
    return $self->{_json} if $self->{_json};

    my $jsonFile = $self->jsonFile();
    if (defined $jsonFile) {
        return $self->{_json} = decode_json($self->_contentsOf($jsonFile));
    }
    return $self->{_json} = {};
}

sub hopefullyExists {
     my ($self, $path) = @_;
     return $path if (-f $path && -s $path != 0);
     return undef;
}

sub deriveTags {
    my ($self) = @_;

    my $json = $self->json();

    my $tags = {};

    # title
    # composer
    # year
    # performer(s)
    # album?
    # track number
    
    return $tags;
}

sub _contentsOf {
    my ($self, $file) = @_;

    open FILE, $file or die "Couldn't open $file";
    my @lines = <FILE>;
    return join(" ", @lines);
}

1;
