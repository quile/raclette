package Raclette::Extractors;

use Try::Tiny;

use Raclette::Extractor;
use Raclette::Extractor::UnsungMasterworks;
use Raclette::Extractor::ComposersbyNumbers;

sub extractorForJSON {
    my ($class, $json) = @_;

    my $n = undef;

    try {
        my $ec = "Raclette::Extractor::".$json->{uploader};
        $n = $ec->new($json);
    } catch {
        print STDERR "No extractor found for user ".$json->{uploader}."\n";
    };

    return $n if $n;
    return Raclette::Extractor->new($json);
}

1;
