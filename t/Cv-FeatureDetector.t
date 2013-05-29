# -*- mode: perl; coding: utf-8; tab-width: 4 -*-

use strict;
use warnings;
use Test::More qw(no_plan);
# use Test::More;
use Test::Exception;
BEGIN { use_ok('Cv') }
BEGIN { use_ok('Cv::FeatureDetector') }

my $verbose = Cv->hasGUI;

use File::Basename;
my $image = cvLoadImage(dirname($0) . "/beaver.png");

my $font = Cv->InitFont(CV_FONT_NORMAL, (0.4) x 2, 0, 1, CV_AA);

# ok: ORB
# not ok: STAR SIFT SURF
for (
	{ FAST => [] },
	{ STAR => [] },
	{ SIFT => [] },
	{ SURF => [ 500 ] },
	{ ORB => [] },
	{ BRISK => [] },
	{ GFTT => [] },
	{ MSER => [ 5, 60, 14400, 0.25, 0.2, 200, 1.01, 0.003, 5 ] },
	{ Dense => [] },
	) {
	my ($k, $v) = %$_;
	my $class = "Cv::FeatureDetector::$k";
	my $detector1 = Cv::FeatureDetector->new($k, @$v);
	isa_ok($detector1, $class);
	my $detector2 = $class->new(@$v);
	isa_ok($detector2, $class);
	my $detector = $detector2;
	my $clone = $image->clone;
	my $keypoints = $detector->detect($clone);
	for (@$keypoints) {
		my ($x, $y) = (10, $image->height - 10);
		$clone->putText($k, [ $x-1, $y-1 ], $font, cvScalarAll(255));
		$clone->putText($k, [ $x+1, $y+1 ], $font, cvScalarAll(0));
		$clone->putText($k, [ $x+0, $y+0 ], $font, cvScalarAll(200));
		my ($pt, $size, $angle, $response, $octave, $class_id) = @$_;
		my $color = [ map { int rand 255 } 1 .. 3 ];
		my ($x0, $y0) = @$pt;
		$angle *= CV_PI / 180;
		my ($x1, $y1) = ($x0 + $size * cos($angle), $y0 + $size * sin($angle));
		$clone->line($pt, [$x1, $y1], $color);
	}
	$clone->show;
	Cv->waitKey(1000);
}
