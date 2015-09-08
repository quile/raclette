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

1;
