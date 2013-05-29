# -*- mode: perl; coding: utf-8; tab-width: 4 -*-

use strict;
use warnings;
use Test::More qw(no_plan);
# use Test::More;
use Test::Exception;
BEGIN { use_ok('Cv') }
BEGIN { use_ok('Cv::FeatureDetector') }

my $verbose = Cv->hasGUI;

use Time::HiRes qw(gettimeofday);
use File::Basename;
my $image = cvLoadImage(dirname($0) . "/beaver.png");

my $font = Cv->InitFont(CV_FONT_NORMAL, (0.6) x 2, 0, 1, CV_AA);

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
	my ($x, $y) = (10, $image->height - 10);
	my $class = "Cv::FeatureDetector::$k";
	my $detector1 = Cv::FeatureDetector->new($k, @$v);
	isa_ok($detector1, $class);
	my $detector2 = $class->new(@$v);
	isa_ok($detector2, $class);
	my $detector = $detector2;
	my $clone = $image->clone;
	my $t0 = gettimeofday();
	my $keypoints = $detector->detect($clone);
	my $ti = sprintf("$k: %.1f(ms)", (gettimeofday() - $t0) * 1000);
	for (@$keypoints) {
		my ($pt, $size, $angle, $response, $octave, $class_id) = @$_;
		$angle *= CV_PI / 180;
		my $color = [ map { 32 + int rand 255 - 32 } 1 .. 3 ];
		my ($x0, $y0) = @$pt;
		my ($x1, $y1) = ($x0 + $size * cos($angle), $y0 + $size * sin($angle));
		$clone->line([$x0, $y0], [$x1, $y1], $color, 2, CV_AA);
	}
	$clone->putText($ti, [ $x-1, $y-1 ], $font, cvScalarAll(250));
	$clone->putText($ti, [ $x+1, $y+1 ], $font, cvScalarAll(50));
	$clone->putText($ti, [ $x+0, $y+0 ], $font, [100, 150, 250]);
	if ($verbose) {
		$clone->show;
		Cv->waitKey(1000);
	}
}
