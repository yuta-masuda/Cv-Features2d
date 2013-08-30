# -*- mode: perl; coding: utf-8; tab-width: 4 -*-

use strict;
use warnings;
use Test::More qw(no_plan);
# use Test::More;
use Test::Exception;
BEGIN { use_ok('Cv', -nonfree) }
BEGIN { use_ok('Cv::Features2d') }

if (1) {
	my @all = @{$Cv::Features2d::EXPORT_TAGS{all}};
	Cv::Features2d->import(':all');
	can_ok(__PACKAGE__, @all);
}

sub usage {
	my $u = join('', @_);
	$u =~ s/[()]/\\$&/g;
	$u =~ s/\s*=\s*/\\s*=\\s*/g;
	qr/[Uu]sage: $u at $0 line \d+\.?/;
}

if (2) {
	lives_ok { SIFT() };
	lives_ok { SURF(500) };
	lives_ok { ORB() };
	lives_ok { BRISK() };
	lives_ok { BFMatcher() };
	lives_ok { FlannBasedMatcher() };
	lives_ok { drawKeypoints(
				   Cv::Mat->new([240, 320], CV_8UC1), [],
				   ) };
	throws_ok { drawKeypoints() } usage(
		'Cv::Features2d::drawKeypoints(',
		join(', ', 'image', 'keypoints', 'color= cvScalarAll(-1)',
			 'flags=DrawMatchesFlags::DEFAULT'), ')',
		);
	lives_ok { drawMatches(
				   Cv::Mat->new([240, 320], CV_8UC1), [],
				   Cv::Mat->new([240, 320], CV_8UC1), [],
				   [] ) };
	throws_ok { drawMatches() } usage(
		'Cv::Features2d::drawMatches(',
		join(', ', 'img1', 'keypoints1', 'img2', 'keypoints2',
			 'matches1to2', 'matchColor= cvScalarAll(-1)',
			 'singlePointColor= cvScalarAll(-1)', 'matchesMask= NULL',
			 'flags= DrawMatchesFlags::DEFAULT'), ')',
		);
	lives_ok { BriefDescriptorExtractor() };
	lives_ok { FREAK() };
}
