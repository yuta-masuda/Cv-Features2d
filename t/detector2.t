# -*- mode: perl; coding: utf-8; tab-width: 4 -*-

use strict;
use warnings;
use Test::More qw(no_plan);
# use Test::More;
use Test::Exception;
BEGIN { use_ok('Cv') }
BEGIN { use_ok('Cv::Features2d', qw(:all)) }

my $image = chessboard();

sub chessboard {
	my $img = Cv->createMat(270, 270, CV_8UC3)
		->fill(cvScalarAll(127));
	for my $i (0 .. 7) {
		for my $j (0 .. 7) {
			my ($x, $y) = ($i * 30 + 15, $j * 30 + 15);
			$img->rectangle(
				[$x, $y], [$x + 30, $y + 30],
				cvScalarAll(($i + $j + 1) % 2? 255 : 0), -1,
				);
		}
	}
	$img;
}

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
