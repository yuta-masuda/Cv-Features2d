# -*- mode: perl; coding: utf-8; tab-width: 4 -*-

use strict;
use warnings;
use Test::More qw(no_plan);
# use Test::Exception;
BEGIN { use_ok('Cv') }
BEGIN { use_ok('Cv::Features2D::ORB') }

my $verbose = Cv->hasGUI;

use File::Basename;
my $image = cvLoadImage(dirname($0) . "/beaver.png");
$image ||= &sample;

my $detector = Cv::Features2D::ORB->new;
isa_ok($detector, 'Cv::Features2D::ORB');

my ($keypoints, $descriptors);
$keypoints = $detector->detect($image, \0);
is(ref $keypoints, 'ARRAY');

($keypoints, $descriptors) = $detector->detect($image);
is(ref $keypoints, 'ARRAY');
isa_ok($descriptors, 'Cv::Mat');

for (@$keypoints) {
	my ($pt1, $size, $angle, $response, $octave, $class_id) = @$_;
	my ($x0, $y0) = @$pt1; $angle *= CV_PI / 180;
	my $pt2 = [ $x0 + $size * cos($angle), $y0 + $size * sin($angle) ];
	my $color = [ map { int rand 255 } 1 .. 3 ];
	$image->line($pt1, $pt2, $color, 1, CV_AA);
	$image->circle($pt2, 3, $color, -1, CV_AA);
}

if ($verbose) {
	$image->show;
	Cv->waitKey(1000);
}


sub sample {
	my $image = Cv::Image->new([300, 300], CV_8UC3);
	my @pt = ([100, 100], [100, 200], [200, 200], [200, 100]);
	$image->polyLine([\@pt], -1, [ 100, 200, 200], 1, CV_AA);
	my $r;
	$image->circle($_, ++$r, [ 100, 255, 255], -1, CV_AA) for @pt;
	$image;
}
