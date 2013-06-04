#!/usr/bin/perl
# -*- mode: perl; coding: utf-8; tab-width: 4; -*-

use strict;
use warnings;
use lib qw(blib/lib blib/arch);
use Cv;
use Cv::Features2d;
use File::Basename;
use Getopt::Long;
use List::Util qw(sum);
use Data::Dumper;

my %opt = map { $_ => 0 } qw(surf sift orb);
GetOptions((map {("--$_" => \$opt{$_})} keys %opt)) && sum(values %opt) <= 1
	|| die "usage: $0 --[".join('|', keys %opt)."] image1 image2\n";

my $detector = $opt{sift} && Cv::Features2d::SIFT->new()
	|| $opt{orb} && Cv::Features2d::ORB->new()
	|| Cv::Features2d::SURF->new(500);

my $fn1 = shift || join('/', dirname($0), "box.png");
my $fn2 = shift || join('/', dirname($0), "box_in_scene.png");
my $img1 = Cv->loadImage($fn1, CV_LOAD_IMAGE_GRAYSCALE);
my $img2 = Cv->loadImage($fn2, CV_LOAD_IMAGE_GRAYSCALE);
die "Can not load $fn1 and/or $fn2\n" unless $img1 && $img2;

my $t = Cv->getTickCount();
my ($kp1, $desc1) = $detector->detectAndCompute($img1);
my ($kp2, $desc2) = $detector->detectAndCompute($img2);
$t = Cv->getTickCount() - $t;

print "$fn1: ", scalar @{$kp1}, " features\n";
print "$fn2: ", scalar @{$kp2}, " features\n";
printf "detect and compute: %gms\n", $t / (Cv->getTickFrequency() * 1000.0);

sub filter_matches {
	my ($kp1, $kp2, $matches, $ratio) = @_;
	$ratio ||= 0.75;
    my @q1; my @q2;
    for (@$matches) {
		next unless @$_ == 2;
		my ($a, $b) = @$_;
		my %a = (queryIdx => $a->[0], trainIdx => $a->[1], distance => $a->[3]);
		my %b = (queryIdx => $b->[0], trainIdx => $b->[1], distance => $b->[3]);
		if ($a{distance} < $b{distance} * $ratio) {
			push(@q1, $kp1->[$a{queryIdx}]->[0]);
			push(@q2, $kp2->[$a{trainIdx}]->[0]);
		}
	}
    (\@q1, \@q2);
}


my $matcher = Cv::Features2d::BFMatcher->new;
my $dmatch = $matcher->knnMatch($desc1, $desc2, 2);
my ($p1, $p2) = filter_matches($kp1, $kp2, $dmatch);

my $image = $img2->cvtColor(CV_GRAY2BGR);
$image->circle($_, 3, [map { 64 + int rand 255 - 64 } 1..3], 1, CV_AA)
	for @$p2;

if (@$p2 >= 4) {
    Cv->findHomography(
		Cv::Mat->new([], CV_32FC2, $p1), Cv::Mat->new([], CV_32FC2, $p2),
		my $H = Cv::Mat->new([3, 3], CV_64F), CV_RANSAC, 5);
	my ($h, $w) = $img1->getDims;
	my $corners = Cv::Mat->new(
		[], CV_32FC2, [0, 0], [$w, 0], [$w, $h], [0, $h]);
	my @corner = @{$corners->PerspectiveTransform($corners->new, $H)};
	$image->polyLine([\@corner], -1, [ 100, 200, 200 ], 2, CV_AA);
}

$image->show;

Cv->waitKey;
