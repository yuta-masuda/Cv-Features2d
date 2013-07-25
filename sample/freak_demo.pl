#!/usr/bin/perl
# -*- mode: perl; coding: utf-8; tab-width: 4; -*-

use strict;
use warnings;
use lib qw(blib/lib blib/arch);
use Cv;
use Cv::Features2d qw(:all);
use File::Basename;
use Getopt::Long;
# use Data::Dumper;

my %detector = map { $_ => 0 } qw(surf sift orb brisk grid pyramid);
my %extractor = map { $_ => 0 } qw(freak brief opponent);
my $verbose = 0;

GetOptions(
	(map {("--$_" => \$detector{$_})} keys %detector),
	(map {("--$_" => \$extractor{$_})} keys %extractor),
	"--verbose" => \$verbose)
	or die ("usage: $0 --[", join('|', (keys %detector), (keys %extractor)),
			"] image1 image2\n");

my $detector = $detector{sift} && SIFT()
	|| $detector{orb} && ORB()
	|| $detector{brisk} && BRISK()
	|| SURF(2000, 4);
if ($detector{grid}) {
	$detector = GridAdaptedFeatureDetector($detector, 500);
}
if ($detector{pyramid}) {
	$detector = PyramidAdaptedFeatureDetector($detector);
}

my $extractor = $extractor{brief} && BriefDescriptorExtractor()
	|| $extractor{freak} && FREAK();
if ($extractor{opponent}) {
	$extractor = OpponentColorDescriptorExtractor($extractor || $detector);
}
$extractor ||= $detector;

use constant NORM_L1 => 2;
use constant NORM_L2 => 4;
use constant NORM_HAMMING => 6;
use constant NORM_HAMMING2 => 7;

my $matcher = $detector =~ /SIFT|SURF/i && BFMatcher(NORM_L2)
	|| BFMatcher(NORM_HAMMING);

if ($verbose) {
	warn "# $_: ", (split('::', ref eval "\$$_"))[-1], "\n"
		for qw(detector extractor matcher);
}

my $color_or_grayscale = $extractor =~ /opponent/i?
	CV_LOAD_IMAGE_COLOR : CV_LOAD_IMAGE_GRAYSCALE;
my $fn1 = shift || join('/', dirname($0), "box.png");
my $fn2 = shift || join('/', dirname($0), "box_in_scene.png");
my $img1 = Cv->loadImage($fn1, $color_or_grayscale);
my $img2 = Cv->loadImage($fn2, $color_or_grayscale);
die "Can not load $fn1 and/or $fn2\n" unless $img1 && $img2;

my $t = Cv->getTickCount();
my $kp1 = $detector->detect($img1);
my $desc1 = $extractor->compute($img1, $kp1);
my $kp2 = $detector->detect($img2);
my $desc2 = $extractor->compute($img2, $kp2);
$t = Cv->getTickCount() - $t;
print "$fn1: ", scalar @{$kp1}, " features\n";
print "$fn2: ", scalar @{$kp2}, " features\n";
printf "detect and compute: %gms\n", $t / (Cv->getTickFrequency() * 1000.0);

my $matches = $matcher->match($desc1, $desc2);
my $imgMatch = drawMatches($img1, $kp1, $img2, $kp2, $matches);
Cv->namedWindow("matches", CV_WINDOW_KEEPRATIO);
$imgMatch->show('matches');
Cv->waitKey;
