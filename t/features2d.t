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
