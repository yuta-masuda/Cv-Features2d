# -*- mode: perl; coding: utf-8; tab-width: 4 -*-

use strict;
use warnings;
use Test::More qw(no_plan);
# use Test::More tests => 13;
BEGIN { use_ok('Cv') }
BEGIN { use_ok('Cv::Features2d', ':all') }

my $verbose = Cv->hasGUI;

use Data::Dumper;

if (1) {
	my $img = Cv::Image->new([300, 300], CV_8UC3);
	my @pt = ([100, 100], [100, 200], [200, 200], [200, 100]);
	$img->polyLine([\@pt], -1, [ 100, 200, 200], 1, CV_AA);
	my $r; $img->circle($_, ++$r, [ 100, 255, 255], -1, CV_AA) for @pt;
	my $gray = $img->cvtColor(CV_BGR2GRAY)->smooth(CV_GAUSSIAN, 5, 5);
	$gray->show('gray') if $verbose;
	my $params = cvSURFParams(my $hessianThreshold = 500, my $extended = 1);
	my $storage = Cv->createMemStorage();
	$gray->extractSURF(\0, my $surfPoint, \0, $storage, $params);
	isa_ok($surfPoint, 'Cv::Seq::SURFPoint');
	# print STDERR Data::Dumper->Dump([\%surfPoint], [qw(*sutfPoint)]);

	my %surfPoint;
	for (@$surfPoint) {
		# see cvExtractSURF() in modules/legacy/src/features2d.cpp
		$surfPoint{sprintf "%g,%g", @{$_->[0]}} = {
			pt        => $_->[0], # kpt[i].pt
			laplacian => $_->[1], # kpt[i].class_id
			size      => $_->[2], # cvRound(kpt[i].size)
			dir       => $_->[3], # kpt[i].angle
			hessian   => $_->[4], # kpt[i].response
		};
	}

	my $surf = SURF(
		$params->[2],			# hessianThreshold
		$params->[3],			# nOctaves
		$params->[4],			# nOctaveLayers
		$params->[1],			# upright
		$params->[0],			# extended
		);
	my $keyPoint = $surf->detect($gray);
	# print STDERR Data::Dumper->Dump([\%keyPoint], [qw(*keyPoint)]);

	my %keyPoint;
	for (@$keyPoint) {
		$keyPoint{sprintf "%g,%g", @{$_->[0]}} = {
			pt        => $_->[0],
			size      => $_->[1],
			angle     => $_->[2],
			response  => $_->[3],
			octave    => $_->[4],
			class_id  => $_->[5],
		};
	}

	is(scalar @$keyPoint, scalar @$surfPoint);

	if ($verbose) {
		$img->show;
		Cv->waitKey(1000);
	}
}
