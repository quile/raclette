package Raclette::Extractors;

use Try::Tiny;

use Raclette::Extractor;
use Raclette::Extractor::UnsungMasterworks;
use Raclette::Extractor::ComposersbyNumbers;
use Raclette::Extractor::KuhlauDilfeng2;
use Raclette::Extractor::MartinJones;

sub _sanitisedUploaderName {
    my ($uploader) = @_;

    $uploader =~ s/[^_A-Z0-9]//ig;
    return $uploader;
}

sub extractorForJSON {
    my ($class, $json) = @_;

    my $n = undef;

    try {
        my $ec = "Raclette::Extractor::"._sanitisedUploaderName($json->{uploader});
        $n = $ec->new($json);
    } catch {
        print STDERR "No extractor found for user ".$json->{uploader}."\n";
    };

    return $n if $n;
    return Raclette::Extractor->new($json);
}

1;
