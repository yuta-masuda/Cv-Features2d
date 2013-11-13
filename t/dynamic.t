# -*- mode: perl; coding: utf-8; tab-width: 4 -*-

use strict;
use warnings;
use Test::More qw(no_plan);
# use Test::More;
BEGIN { use_ok('Cv', -nonfree) }
BEGIN { use_ok('Cv::Features2d', qw(:all)) }

my $verbose = Cv->hasGUI;

use Time::HiRes qw(gettimeofday);
my $image = chessboard();

sub chessboard {
	my $img = Cv->createMat(270, 270, CV_8UC3)
		->fill(cvScalarAll(127));
	for my $i (0 .. 7) {
		for my $j (0 .. 7) {
			my ($x, $y) = ($i * 30 + 15, $j * 30 + 15);
			$img->rectangle(
				[$x, $y], [$x + 30, $y + 30],
				cvScalarAll(($i + $j + 1) % 2? 255 : 0), -1,
				);
		}
	}
	$img;
}

my $font = Cv->InitFont(CV_FONT_NORMAL, (0.4) x 2, 0, 1, CV_AA);
if ($verbose) {
	Cv->namedWindow('Cv', 0);
}

if (1) {
	my $fast = FastAdjuster();
	my $star = StarAdjuster();
	my $surf = SurfAdjuster();
}

if (2) {
	my $fast = FastAdjuster();
	my $star = StarAdjuster();
	my $surf = SurfAdjuster();
  SKIP: {
	  skip "Test::Exception required", 2 unless eval "use Test::Exception";
	  lives_ok { $fast->DESTROY; };
	  lives_ok { $star->DESTROY; };
	  lives_ok { $surf->DESTROY; };
	}
}

if (3) {
	for (
		FastAdjuster(),
		StarAdjuster(),
		SurfAdjuster(),
		) {
		my $detector;
	  SKIP: {
		  skip "Test::Exception required", 2 unless eval "use Test::Exception";
		  lives_ok { $detector = DynamicAdaptedFeatureDetector($_); };
		  lives_ok { $detector->DESTROY; };
		}
	}
}

for (
	FastAdjuster(),
	StarAdjuster(),
	SurfAdjuster(),
	) {
	my $detector = DynamicAdaptedFeatureDetector($_);
	(my $name = "Dynamic+" . (split('::', ref $_))[-1]) =~ s/Adjuster//g;
	ok($detector, $name);
	my $oimage = $image->cvtColor(CV_BGR2GRAY)->cvtColor(CV_GRAY2BGR);
	my $t0 = gettimeofday();
	my $keypoints = $detector->detect($image);
	diag($name) unless @$keypoints;
	my $ti = sprintf("$name: %.1f(ms)", (gettimeofday() - $t0) * 1000);
	my ($x, $y) = (10, $image->height - 10);
	$oimage->drawKeypoints($keypoints, cvScalarAll(-1), 4);
	$oimage->putText($ti, [ $x-1, $y-1 ], $font, cvScalarAll(250));
	$oimage->putText($ti, [ $x+1, $y+1 ], $font, cvScalarAll(50));
	$oimage->putText($ti, [ $x+0, $y+0 ], $font, [100, 220, 220]);
	if ($verbose) {
		$oimage->show;
		Cv->waitKey(1000);
	}
}

my $detector = DynamicAdaptedFeatureDetector(FastAdjuster());
isa_ok($detector, 'Cv::Features2d::FeatureDetector');
can_ok($detector, qw(detect));
