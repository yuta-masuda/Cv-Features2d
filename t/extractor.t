# -*- mode: perl; coding: utf-8; tab-width: 4 -*-

use strict;
use warnings;
use Test::More qw(no_plan);
# use Test::More;
use Test::Exception;
BEGIN { use_ok('Cv', -nonfree) }
BEGIN { use_ok('Cv::Features2d', qw(:all)) }

for my $extractor (
	# DescriptorExtractor
	FREAK(),
	BriefDescriptorExtractor(),
	# Feature2D
	SIFT(),
	SURF(500),
	ORB(),
	BRISK(),
	# # OpponentColorDescriptorExtractor
	# (map OpponentColorDescriptorExtractor($_), qw(SIFT SURF ORB BRISK BRIEF),
	#  SIFT(), SURF(500), ORB(), BRISK(), BriefDescriptorExtractor())
	) {
	isa_ok($extractor, 'Cv::Features2d::DescriptorExtractor');
	can_ok($extractor, qw(compute));
}
