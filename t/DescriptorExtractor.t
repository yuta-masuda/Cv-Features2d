# -*- mode: perl; coding: utf-8; tab-width: 4 -*-

use strict;
use warnings;
use Test::More qw(no_plan);
# use Test::More;
use Test::Exception;
BEGIN { use_ok('Cv') }
BEGIN { use_ok('Cv::FeatureDetector') }
BEGIN { use_ok('Cv::DescriptorExtractor') }

my $verbose = Cv->hasGUI;

use File::Basename;
my $image = cvLoadImage(dirname($0) . "/beaver.png");

my $font = Cv->InitFont(CV_FONT_NORMAL, (0.6) x 2, 0, 1, CV_AA);

my $orb = Cv::FeatureDetector::ORB->new;
isa_ok($orb, 'Cv::FeatureDetector');
my $keypoints = $orb->detect($image);

for (
	{ BRIEF => [] },
	# { ORB => [] },
	) {
	my ($k, $v) = %$_;
	my $class = "Cv::DescriptorExtractor::$k";
	my $extractor = $class->new(@$v);
	isa_ok($extractor, $class);
	my $descriptor = $extractor->compute($image, $keypoints);
	isa_ok($descriptor, 'Cv::Mat');
}

