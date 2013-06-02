# -*- mode: perl; coding: utf-8; tab-width: 4 -*-

use strict;
use warnings;
use Test::More;
eval "use Test::Pod::Coverage";
plan skip_all => "Test::Pod::Coverage required for testing pod coverage" if $@;
plan tests => 2;
pod_coverage_ok("Cv::Features2d");
pod_coverage_ok("Cv::Features2d::FeatureDetector");
# pod_coverage_ok('Cv::Features2d::FastFeatureDetector');
# pod_coverage_ok('Cv::Features2d::StarFeatureDetector');
# pod_coverage_ok('Cv::Features2d::SIFT');
# pod_coverage_ok('Cv::Features2d::SURF');
# pod_coverage_ok('Cv::Features2d::ORB');
# pod_coverage_ok('Cv::Features2d::BRISK');
# pod_coverage_ok('Cv::Features2d::GoodFeaturesToTrackDetector');
# pod_coverage_ok('Cv::Features2d::MserFeatureDetector');
# pod_coverage_ok('Cv::Features2d::DenseFeatureDetector');
