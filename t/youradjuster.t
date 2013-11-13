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

{
	package Your::FastAdjuster;
    our @ISA = qw(Cv::Features2d::FastAdjuster);
    our ($THRESH, $INIT_THRESH, $MIN_THRESH, $MAX_THRESH);
    sub tooFew { $THRESH--; }
    sub tooMany { $THRESH++; }
	our $good = 0;
    sub good { $good++; $THRESH > $MIN_THRESH && $THRESH < $MAX_THRESH; }
}

{
	package Your::StarAdjuster;
	our @ISA = qw(Cv::Features2d::StarAdjuster);
	our ($THRESH, $INIT_THRESH, $MIN_THRESH, $MAX_THRESH);
	sub tooFew { $THRESH *= 0.9; $THRESH = 1.1 if $THRESH < 1.1; }
	sub tooMany { $THRESH *= 1.1; }
	our $good = 0;
	sub good { $good++; $THRESH > $MIN_THRESH && $THRESH < $MAX_THRESH; }
}

{
	package Your::SurfAdjuster;
	our @ISA = qw(Cv::Features2d::SurfAdjuster);
	our ($THRESH, $INIT_THRESH, $MIN_THRESH, $MAX_THRESH);
	sub tooFew { $THRESH *= 0.9; $THRESH = 1.1 if $THRESH < 1.1; }
	sub tooMany { $THRESH *= 1.1; }
	our $good = 0;
	sub good { $good++; $THRESH > $MIN_THRESH && $THRESH < $MAX_THRESH; }
}

for my $YourAdjuster (
	qw(Your::FastAdjuster Your::StarAdjuster Your::SurfAdjuster)
	) {
	my $detector = DynamicAdaptedFeatureDetector($YourAdjuster->new());
	my $oimage = $image->cvtColor(CV_BGR2GRAY)->cvtColor(CV_GRAY2BGR);
	my $t0 = gettimeofday();
	my $keypoints = $detector->detect($image);
	my $goodVar = "\$${YourAdjuster}::good";
	my $good = eval $goodVar;
	ok($good, $goodVar);
	diag($YourAdjuster) unless @$keypoints;
	my $ti = sprintf("$YourAdjuster: %.1f(ms)", (gettimeofday() - $t0) * 1000);
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

