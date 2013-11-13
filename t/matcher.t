# -*- mode: perl; coding: utf-8; tab-width: 4 -*-

use strict;
use warnings;
use Test::More qw(no_plan);
# use Test::More;
# use Test::Exception;
BEGIN { use_ok('Cv') }
BEGIN { use_ok('Cv::Features2d', qw(:all)) }

for my $matcher (
	# DescriptorMatcher
	BFMatcher(),
	FlannBasedMatcher(),
	) {
	isa_ok($matcher, 'Cv::Features2d::DescriptorMatcher');
	can_ok($matcher, qw(match knnMatch radiusMatch));
}

