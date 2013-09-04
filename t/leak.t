# -*- mode: perl; coding: utf-8; tab-width: 4 -*-

use strict;
use warnings;
use constant HAS_LEAKTRACE => eval{ require Test::LeakTrace };
use Test::More HAS_LEAKTRACE? (tests => 13) : (skip_all => 'require Test::LeakTrace');
use Test::LeakTrace;

BEGIN { use_ok('Cv', -nonfree) }
BEGIN { use_ok('Cv::Features2d', qw(:all)) }

no_leaks_ok { SIFT() };
no_leaks_ok { SIFT()->new() };
no_leaks_ok { GridAdaptedFeatureDetector(SIFT()) };
no_leaks_ok { GridAdaptedFeatureDetector(my $sift = SIFT()) };
no_leaks_ok { PyramidAdaptedFeatureDetector(SIFT()) };
no_leaks_ok { PyramidAdaptedFeatureDetector(my $sift = SIFT()) };
no_leaks_ok { FastAdjuster() };
no_leaks_ok { StarAdjuster() };
no_leaks_ok { SurfAdjuster() };
no_leaks_ok { DynamicAdaptedFeatureDetector(FastAdjuster()) };
no_leaks_ok { DynamicAdaptedFeatureDetector(my $fast = FastAdjuster()) };
