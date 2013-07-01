# -*- mode: perl; coding: utf-8; tab-width: 4 -*-

use strict;
use warnings;
use Test::More qw(no_plan);
# use Test::More;
use Test::Exception;
BEGIN { use_ok('Cv') }
BEGIN { use_ok('Cv::Features2d', qw(:all)) }

use File::Basename;
my $image = cvLoadImage(dirname($0) . "/beaver.png");

for my $detector (
	# Feature2D
	SIFT(),
	SURF(500),
	ORB(),
	BRISK(),
	# FeatureDetector
	FastFeatureDetector(),
	StarFeatureDetector(),
	GoodFeaturesToTrackDetector(),
	MserFeatureDetector(5, 60, 14400, 0.25, 0.2, 200, 1.01, 0.003, 5),
	DenseFeatureDetector(),
	) {
	my $kvv = $detector->detect([($image) x 10]);
	is(scalar @$kvv, 10);
}
