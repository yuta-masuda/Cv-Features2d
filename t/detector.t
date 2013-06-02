# -*- mode: perl; coding: utf-8; tab-width: 4 -*-

use strict;
use warnings;
use Test::More qw(no_plan);
# use Test::More;
use Test::Exception;
BEGIN { use_ok('Cv') }
BEGIN { use_ok('Cv::Features2d') }

my $verbose = Cv->hasGUI;

use Time::HiRes qw(gettimeofday);
use File::Basename;
my $image = cvLoadImage(dirname($0) . "/beaver.png");

my $font = Cv->InitFont(CV_FONT_NORMAL, (0.5) x 2, 0, 1, CV_AA);

for (
	{ 'FastFeatureDetector' => [] },
	{ 'StarFeatureDetector' => [] },
	{ 'SIFT' => [] },
	{ 'SURF' => [ 500 ] },
	{ 'ORB' => [] },
	{ 'BRISK' => [] },
	{ 'GoodFeaturesToTrackDetector' => [] },
	{ 'MserFeatureDetector' => [ 5, 60, 14400, 0.25, 0.2, 200, 1.01, 0.003, 5 ] },
	{ 'DenseFeatureDetector' => [] },
	) {
	my ($k, $args) = %$_; my $class = "Cv::Features2d::$k";
	my $detector = $class->new(@$args);
	isa_ok($detector, $class);
	my $outImage = $image->clone;
	my $t0 = gettimeofday();
	my $keypoints = $detector->detect($outImage);
	my $ti = sprintf("$k: %.1f(ms)", (gettimeofday() - $t0) * 1000);
	for (@$keypoints) {
		my ($pt, $size, $angle, $response, $octave, $class_id) = @$_;
		$angle *= CV_PI / 180;
		my $color = [ map { 32 + int rand 255 - 32 } 1 .. 3 ];
		my ($x0, $y0) = @$pt;
		my ($x1, $y1) = ($x0 + $size * cos($angle), $y0 + $size * sin($angle));
		$outImage->line([$x0, $y0], [$x1, $y1], $color, 2, CV_AA);
	}
	my ($x, $y) = (10, $image->height - 10);
	$outImage->putText($ti, [ $x-1, $y-1 ], $font, cvScalarAll(250));
	$outImage->putText($ti, [ $x+1, $y+1 ], $font, cvScalarAll(50));
	$outImage->putText($ti, [ $x+0, $y+0 ], $font, [100, 150, 250]);
	my $outImage2 = Cv::Features2d::drawKeypoints($image, $keypoints);
	if ($verbose) {
		$outImage->show('keypoints');
		$outImage2->show('drawKeypoints');
		Cv->waitKey(1000);
	}
}
