# -*- mode: perl; coding: utf-8; tab-width: 4; -*-

=encoding utf8

=head1 NAME

Cv::Features2d - Cv extension for OpenCV Features Detector

=head1 SYNOPSIS

  use Cv::Features2d qw(SURF drawKeypoints);
  my $gray = Cv->loadImage(shift, CV_LOAD_IMAGE_GRAYSCALE);
  my $surf = SURF(500);
  my $keypoints = $surf->detect($gray);
  my $color = $gray->cvtColor(CV_GRAY2BGR);
  drawKeypoints($color, $keypoints);
  $color->show;
  Cv->waitKey;

=cut

package Cv::Features2d;

use 5.008008;
use strict;
use warnings;
use Cv ();

our $VERSION = '0.04';

require XSLoader;
XSLoader::load('Cv::Features2d', $VERSION);

require Exporter;

our @ISA = qw(Exporter);

our @EXPORT_OK = (qw(drawKeypoints drawMatches));
our %EXPORT_TAGS = ( 'all' => \@EXPORT_OK );
our @EXPORT = ( );

for (classes(__PACKAGE__)) {
	if ($_->can('new')) {
		my $name = (split('::', $_))[-1];
		eval "sub $name { ${_}->new(\@_) }";
		push(@EXPORT_OK, $name);
	}
}

sub classes {
	my @list = ();
	for my $base (@_) {
		for (keys %{eval "\\%${base}::"}) {
			if (/^(\w+)::$/) {
				push(@list, &classes("${base}::$1"));
			}
		}
		push(@list, $base);
	}
	@list;
}

=head1 DESCRIPTION

=head2 METHOD

=over

=item SIFT, SURF, ORB, BRISK

  my $f2d = SIFT();
  my $f2d = SURF(500);
  my $f2d = ORB();
  my $f2d = BRISK();

L<SIFT()|http://docs.opencv.org/search.html?q=SIFT>,
L<SURF()|http://docs.opencv.org/search.html?q=SURF>,
L<ORB()|http://docs.opencv.org/search.html?q=ORB>, and
L<BRISK()|http://docs.opencv.org/search.html?q=BRISK> are constructors
of Feature2D.

  my ($kp, $desc) = $f2d->detectAndCompute($img, $mask);
  my $kp = $f2d->detect($img, $mask);
  my $desc = $f2d->compute($img, $kp);

Feature2D inherits from FeatureDetector and DescriptorExtractor.  So
the object can call methods of DescriptorExtractor and
FeatureDetector.

=cut

{
	package Cv::Features2d::FeatureDetector;
	package Cv::Features2d::DescriptorExtractor;
	package Cv::Features2d::Feature2D;
	our @ISA = qw(Cv::Features2d::FeatureDetector Cv::Features2d::DescriptorExtractor);
	for (qw(SIFT SURF ORB BRISK)) {
		my $base = __PACKAGE__;
		eval "package ${base}::$_; our \@ISA = qw(${base})";
	}
}

=item FastFeatureDetector, StarFeatureDetector, MserFeatureDetector,
	GoodFeaturesToTrackDetector, DenseFeatureDetector

  my $detector = FastFeatureDetector();
  my $detector = StarFeatureDetector();
  my $detector = MserFeatureDetector();
  my $detector = GoodFeaturesToTrackDetector();
  my $detector = DenseFeatureDetector();

L<FastFeatureDetector()|http://docs.opencv.org/search.html?q=FastFeatureDetector>,
L<StarFeatureDetector()|http://docs.opencv.org/search.html?q=StarFeatureDetector>,
L<MserFeatureDetector()|http://docs.opencv.org/search.html?q=MserFeatureDetector>,
L<GoodFeaturesToTrackDetector()|http://docs.opencv.org/search.html?q=GoodFeaturesToTrackDetector>,
and
L<DenseFeatureDetector()|http://docs.opencv.org/search.html?q=DenseFeatureDetector>
are constructors of DenseFeatureDetector.

  my $kp = $detector->detect($img, $mask);

=cut

{
	package Cv::Features2d::FeatureDetector;
	for (qw(FastFeatureDetector StarFeatureDetector MserFeatureDetector
		GoodFeaturesToTrackDetector DenseFeatureDetector)) {
		my $base = __PACKAGE__;
		eval "package ${base}::$_; our \@ISA = qw(${base})";
	}
}

=item FREAK

  my $extractor = FREAK();

L<FREAK()|http://docs.opencv.org/search.html?q=FREAK> is a
constructor of Descriptor Extractors.

  my $desc = $extractor->compute($img, $kp);

=cut

{
	package Cv::Features2d::DescriptorExtractor;
	for (qw(BriefDescriptorExtractor FREAK)) {
		my $base = __PACKAGE__;
		eval "package ${base}::$_; our \@ISA = qw(${base})";
	}
}

=item BFMatcher, FlannBasedMatcher

  my $matcher = BFMatcher();

L<BFMatcher()|http://docs.opencv.org/search.html?q=BFMatcher> is a
constructor of Descriptor Matchers.

  my $matches = $matcher->match($desc, $desc2, $mask);
  my $matches = $matcher->knnMatch($desc, $desc2, $k, $mask, $compact);
  my $matches = $matcher->radiusMatch($desc, $desc2, $maxDist, $mask, $compact);

L<FlannBasedMatcher()|http://docs.opencv.org/search.html?q=FlannBasedMatcher>
is a also constructor.  The parameters are hashrefs as follows:

  my $matcher = FlannBasedMatcher($indexParams, $searchParams);
  my $matcher = FlannBasedMatcher(
    my $indexParams = {
      algorithm => 6,
      table_number => 6,
      key_size => 12,
      multi_probe_level => 1,
    });

To define LshIndexParams (one of IndexParams).

  my $searchParams = {
    'checks:i' => 32,       # int
    'eps:f' => 0,           # float
    'sorted:b' => 1,        # bool
  };

IndexParams stores the key-value pairs. The type of the value stored
in the IndexParams is more detailed than Perl SV.  There are double,
float, int, bool, and string.  To clarify the type of them, you can
put a letter with colon after the name.  The letter is as following.

  letter  | type of IndexParams
 ------------------------------------
     d    |    double
     f    |    float
     i    |    int
     b    |    bool
     a    |    string

If there is no type letter, the type of IndexParams is mapped from
sv-type.

  sv-type | type of IndexParams
 ------------------------------------
    NV    |    double
    IV    |    int
    PV    |    string

Please see the samples in t/indexparam.t and sample/find_obj.pl.

=cut

{
	package Cv::IndexParams;
	our $VERBOSE = 0;
	package Cv::Features2d::DescriptorMatcher;
	for (qw(BFMatcher FlannBasedMatcher)) {
		my $base = __PACKAGE__;
		eval "package ${base}::$_; our \@ISA = qw(${base})";
	}
}

=item drawKeypoints, drawMatches

  drawKeypoints($image, $keypoints, $color, $flags);
  my $image = drawMatches($img1, $keypoints1, $img2, $keypoints2);

=cut

*Cv::Arr::drawKeypoints = \&drawKeypoints;
*Cv::Arr::drawMatches = \&drawMatches;

1;
__END__

=back

=head2 EXPORT

None by default.


=head1 SEE ALSO

http://github.com/yuta-masuda/Cv-Features2d


=head1 AUTHOR

MASUDA Yuta E<lt>yuta.cpan@gmail.comE<gt>


=head1 LICENCE

Copyright (c) 2013 by MASUDA Yuta.

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl itself.

=cut
