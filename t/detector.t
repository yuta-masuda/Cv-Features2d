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
	{ 'Cv::Features2d::Feature2D::SIFT' => [] },
	{ 'Cv::Features2d::Feature2D::SURF' => [ 500 ] },
	{ 'Cv::Features2d::Feature2D::ORB' => [] },
	{ 'Cv::Features2d::Feature2D::BRISK' => [] },
	{ 'Cv::Features2d::FeatureDetector::FastFeatureDetector' => [] },
	{ 'Cv::Features2d::FeatureDetector::StarFeatureDetector' => [] },
	{ 'Cv::Features2d::FeatureDetector::GoodFeaturesToTrackDetector' => [] },
	{ 'Cv::Features2d::FeatureDetector::MserFeatureDetector' =>
		  [ 5, 60, 14400, 0.25, 0.2, 200, 1.01, 0.003, 5 ] },
	{ 'Cv::Features2d::FeatureDetector::DenseFeatureDetector' => [] },
	) {
	my ($class, $args) = %$_;
	my $k = (split('::', $class))[-1];
	my $detector = $class->new(@$args);
	isa_ok($detector, $class);
	my $outImage1 = $image->clone;
	my $outImage2 = $image->clone;
	my $t0 = gettimeofday();
	my $keypoints = $detector->detect($image);
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
	Cv::Features2d::drawKeypoints($outImage2, $keypoints);
	if ($verbose) {
		$outImage1->show('keypoints');
		$outImage2->show('drawKeypoints');
		Cv->waitKey(1000);
	}
}
