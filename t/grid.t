# -*- mode: perl; coding: utf-8; tab-width: 4 -*-

use strict;
use warnings;
use Test::More qw(no_plan);
# use Test::More;
use Test::Exception;
BEGIN { use_ok('Cv') }
BEGIN { use_ok('Cv::Features2d', qw(:all)) }

# my $detector = FastFeatureDetector(10, 1);
my $detector = SURF(500);
isa_ok($detector, 'Cv::Features2d::Feature2D');
can_ok($detector, qw(detect detectAndCompute compute));

isa_ok($detector, 'Cv::Features2d::FeatureDetector');
can_ok($detector, qw(detect));

my $extractor = $detector;
isa_ok($extractor, 'Cv::Features2d::DescriptorExtractor');
can_ok($extractor, qw(compute));

my $grid_detector = GridAdaptedFeatureDetector($detector, 500);
isa_ok($grid_detector, 'Cv::Features2d::FeatureDetector');
can_ok($grid_detector, qw(detect));

isa_ok($extractor, 'Cv::Features2d::DescriptorExtractor');
can_ok($extractor, qw(compute));
