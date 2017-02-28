package Raclette::Utilities;

use strict;
use warnings;

# Yes I know, this is available on CPAN.  But I don't want to
# add any CPAN deps if I can help it.

sub roman {
    my ($num) = @_;

    return "I"    if $num == 1;
    return "II"   if $num == 2;
    return "III"  if $num == 3;
    return "IV"   if $num == 4;
    return "V"    if $num == 5;
    return "VI"   if $num == 6;
    return "VII"  if $num == 7;
    return "VIII" if $num == 8;
    return "IX"   if $num == 9;
    return "X"    if $num == 10;
    return $num;
}

sub arabic {
    my ($roman) = @_;

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

sub titleCase {
    my $s = shift;
    $s =~ s/(\w\S*)/\u\L$1/g;
    return $s;
}

1;
