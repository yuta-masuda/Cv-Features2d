# -*- mode: perl; coding: utf-8; tab-width: 4 -*-

use strict;
use warnings;
use Test::More;
eval "use Test::Pod::Coverage";
plan skip_all => "Test::Pod::Coverage required for testing pod coverage" if $@;
plan tests => 5;

my @todo = qw(
    DenseFeatureDetector
    FastFeatureDetector
    GoodFeaturesToTrackDetector
    MserFeatureDetector
    StarFeatureDetector
    BriefDescriptorExtractor
);

my @private = qw(
	classes
);

pod_coverage_ok("Cv::Features2d", { trustme => [@todo, @private] });
pod_coverage_ok("Cv::Features2d::Feature2D");
pod_coverage_ok("Cv::Features2d::FeatureDetector");
pod_coverage_ok("Cv::Features2d::DescriptorExtractor");
pod_coverage_ok("Cv::Features2d::DescriptorMatcher");
