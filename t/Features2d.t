# -*- mode: perl; coding: utf-8; tab-width: 4 -*-

use strict;
use warnings;
use Test::More qw(no_plan);
# use Test::More;
use Test::Exception;
BEGIN { use_ok('Cv') }
BEGIN { use_ok('Cv::Features2d') }

if (1) {
	my @method = qw(create detect);
	can_ok('Cv::Features2d::FeatureDetector', @method);
	can_ok('Cv::Features2d::FastFeatureDetector', (@method, qw(new)));
	can_ok('Cv::Features2d::StarFeatureDetector', (@method, qw(new)));
	can_ok('Cv::Features2d::SIFT', (@method, qw(new)));
	can_ok('Cv::Features2d::SURF', (@method, qw(new)));
	can_ok('Cv::Features2d::ORB', (@method, qw(new)));
	can_ok('Cv::Features2d::BRISK', (@method, qw(new)));
	can_ok('Cv::Features2d::GoodFeaturesToTrackDetector', (@method, qw(new)));
	can_ok('Cv::Features2d::MserFeatureDetector', (@method, qw(new)));
	can_ok('Cv::Features2d::DenseFeatureDetector', (@method, qw(new)));
}


