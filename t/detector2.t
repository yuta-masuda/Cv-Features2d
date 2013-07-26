# -*- mode: perl; coding: utf-8; tab-width: 4 -*-

use strict;
use warnings;
use Test::More qw(no_plan);
# use Test::More;
use Test::Exception;
BEGIN { use_ok('Cv') }
BEGIN { use_ok('Cv::Features2d', qw(:all)) }

my $verbose = Cv->hasGUI;

use Time::HiRes qw(gettimeofday);
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

my $font = Cv->InitFont(CV_FONT_NORMAL, (0.4) x 2, 0, 1, CV_AA);
if ($verbose) {
	Cv->namedWindow('Cv', 0);
}

for (
	# Feature2D
	SIFT(),
	SURF(500),
	ORB(),
	# BRISK(),
	# FeatureDetector
	FastFeatureDetector(10, 0),
	StarFeatureDetector(),
	# GoodFeaturesToTrackDetector(),
	# MserFeatureDetector(5, 60, 14400, 0.25, 0.2, 200, 1.01, 0.003, 5),
	# DenseFeatureDetector(),
	) {
	my $name = "GridAdaptedFeatureDetector+" . (split('::', ref $_))[-1];
	test_detect(GridAdaptedFeatureDetector($_, 500), $name);
}

for (
	# Feature2D
	SIFT(),
	SURF(500),
	ORB(),
	BRISK(),
	# FeatureDetector
	FastFeatureDetector(10, 0),
	StarFeatureDetector(),
	# GoodFeaturesToTrackDetector(),
	# MserFeatureDetector(5, 60, 14400, 0.25, 0.2, 200, 1.01, 0.003, 5),
	# DenseFeatureDetector(),
	) {
	my $name = "PyramidAdaptedFeatureDetector+" .(split('::', ref $_))[-1];
	test_detect(PyramidAdaptedFeatureDetector($_), $name);
}

sub test_detect {
	my $detector = shift;
	(my $name = shift) =~ s/(Adapted|FeatureDetector)//g;
	my $oimage = $image->cvtColor(CV_BGR2GRAY)->cvtColor(CV_GRAY2BGR);
	my $t0 = gettimeofday();
	my $keypoints = $detector->detect($image);
	diag($name) unless @$keypoints;
	my $ti = sprintf("$name: %.1f(ms)", (gettimeofday() - $t0) * 1000);
	my ($x, $y) = (10, $image->height - 10);
	$oimage->drawKeypoints($keypoints, cvScalarAll(-1), 4);
	$oimage->putText($ti, [ $x-1, $y-1 ], $font, cvScalarAll(250));
	$oimage->putText($ti, [ $x+1, $y+1 ], $font, cvScalarAll(50));
	$oimage->putText($ti, [ $x+0, $y+0 ], $font, [100, 220, 220]);
	if ($verbose) {
		$oimage->show;
		Cv->waitKey(1000);
	}
}
