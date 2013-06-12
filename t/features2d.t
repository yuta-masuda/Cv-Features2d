# -*- mode: perl; coding: utf-8; tab-width: 4 -*-

use strict;
use warnings;
use Test::More qw(no_plan);
# use Test::More;
use Test::Exception;
BEGIN { use_ok('Cv') }
BEGIN { use_ok('Cv::Features2d') }

if (1) {
	my @all = @{$Cv::Features2d::EXPORT_TAGS{all}};
	Cv::Features2d->import(':all');
	can_ok(__PACKAGE__, @all);
}

if (2) {
	lives_ok { SIFT() };
	lives_ok { SURF(500) };
	lives_ok { ORB() };
	lives_ok { BRISK() };
	lives_ok { BFMatcher() };
	lives_ok { FlannBasedMatcher() };
	lives_ok { Cv::Mat->new([240, 320], CV_8UC1)->drawKeypoints([]) };
	lives_ok { BriefDescriptorExtractor() };
	lives_ok { FREAK() };
}
