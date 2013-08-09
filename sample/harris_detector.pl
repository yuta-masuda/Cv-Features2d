#!/usr/bin/perl
# -*- mode: perl; coding: utf-8; tab-width: 4; -*-

# http://docs.opencv.org/doc/tutorials/ \
#   features2d/trackingmotion/harris_detector/harris_detector.html

use strict;
use warnings;
use Cv;
use Cv::Features2d qw(:all);

# Global variables
my $thresh = 200;
my $max_thresh = 255;

my $source_window = "Source image";
my $corners_window = "Corners detected";

# Load source image and convert it to gray
my $gray = (my $src = Cv->loadImageM($ARGV[0], 1))->cvtColor(CV_BGR2GRAY);

# Create a window and a trackbar
Cv->namedWindow($source_window, CV_WINDOW_AUTOSIZE);
Cv->createTrackbar("Threshold: ", $source_window, $thresh, $max_thresh, \&cornerHarris_demo);
$src->show($source_window);
&cornerHarris_demo;
Cv->waitKey(0);

sub cornerHarris_demo {
	# Detector parameters
	my $blockSize = 2;
	my $apertureSize = 3;
	my $k = 0.04;

	# Detecting corners
	my $dst = $gray->cornerHarris($blockSize, $apertureSize, $k);

	# Normalizing
	use constant NORM_MINMAX => 32;
	my $dst_norm = $dst->normalize(0, 255, NORM_MINMAX);
	my $dst_norm_scaled = $dst_norm->cvtScaleAbs()->cvtColor(CV_GRAY2BGR);
	$dst_norm = $dst_norm->cvtScale($dst->new(CV_8UC1));

	# Drawing a circle around corners
	$dst_norm_scaled->circle($_, 5, [0, 0, 255], 2)
		for nonzero($dst_norm->Sub(cvScalar($thresh)));

	# Showing the result
	$dst_norm_scaled->show($corners_window);
}


sub nonzero { @{nonzero_(@_)} }

use Cv::Config;
use Inline C => Config => %Cv::Config::C;
use Inline C => << '----';

AV*
nonzero_(CvArr* src)
{
	CvSize size = cvGetSize(src);
	AV* RETVAL = newAV();
	int i, j;
	for (j = 0; j < size.height; j++) {
		uchar* line = cvPtr2D(src, j, 0);
		for (i = 0; i < size.width; i++) {
			if (line[i]) {
				AV* pt = newAV();
				av_push(pt, newSViv(i));
				av_push(pt, newSViv(j));
				av_push(RETVAL, newRV_inc(sv_2mortal((SV*)pt)));
			}
		}
	}
	return RETVAL;
}

----
