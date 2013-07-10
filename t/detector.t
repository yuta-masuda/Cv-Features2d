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
	isa_ok($detector, 'Cv::Features2d::FeatureDetector');
	if ($detector->isa('Cv::Features2d::Feature2D')) {
		can_ok($detector, qw(detect detectAndCompute compute));
	} else {
		can_ok($detector, qw(detect));
	}
	my $outImage1 = $image->clone;
	my $outImage2 = $image->clone;
	my $t0 = gettimeofday();
	my $keypoints = $detector->detect($image);
	my $k = (split('::', ref $detector))[-1];
	my $ti = sprintf("$k: %.1f(ms)", (gettimeofday() - $t0) * 1000);
	for (@$keypoints) {
		my ($pt, $size, $angle, $response, $octave, $class_id) = @$_;
		$angle *= CV_PI / 180;
		my $color = [ map { 32 + int rand 255 - 32 } 1 .. 3 ];
		my ($x0, $y0) = @$pt;
		my ($x1, $y1) = ($x0 + $size * cos($angle), $y0 + $size * sin($angle));
		$outImage1->line([$x0, $y0], [$x1, $y1], $color, 2, CV_AA);
	}
	my ($x, $y) = (10, $image->height - 10);
	$outImage1->putText($ti, [ $x-1, $y-1 ], $font, cvScalarAll(250));
	$outImage1->putText($ti, [ $x+1, $y+1 ], $font, cvScalarAll(50));
	$outImage1->putText($ti, [ $x+0, $y+0 ], $font, [100, 150, 250]);
	drawKeypoints($outImage2, $keypoints);
	if ($verbose) {
		$outImage1->show('keypoints');
		$outImage2->show('drawKeypoints');
		Cv->waitKey(1000);
	}

	my $mask = $image->new(CV_8UC1)->zero;
	$mask->rectangle([0, 0], [ $mask->width/2, $mask->height/2 ],
					 cvScalarAll(255), -1);
	my $quarter = $detector->detect($image, $mask);
	cmp_ok(scalar @$quarter, '<=', @$keypoints);
}
