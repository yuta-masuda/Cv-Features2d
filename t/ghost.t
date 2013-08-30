# -*- mode: perl; coding: utf-8; tab-width: 4 -*-

use strict;
use warnings;
use Test::More qw(no_plan);
# use Test::More;
use Test::Exception;
BEGIN { use_ok('Cv', -nonfree) }
BEGIN { use_ok('Cv::Features2d', qw(:all)) }

while (my ($name, $package) = each %Cv::Features2d::CLASS) {
	my @isa = eval "\@${package}::Ghost::ISA";
	is($isa[0], $package);
	my $ghost = "${package}::Ghost";
	lives_ok { $ghost->DESTROY };
}
