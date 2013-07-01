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

our $VERSION = '0.05';

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

=item
L<SIFT()|http://docs.opencv.org/search.html?q=SIFT>,
L<SURF()|http://docs.opencv.org/search.html?q=SURF>,
L<ORB()|http://docs.opencv.org/search.html?q=ORB>,
L<BRISK()|http://docs.opencv.org/search.html?q=BRISK>

  my $f2d = SIFT();
  my $f2d = SURF(500);
  my $f2d = ORB();
  my $f2d = BRISK();

=over

=item
L<detectAndCompute()|http://docs.opencv.org/search.html?q=detectAndCompute>

=back

  my ($kp, $desc) = $f2d->detectAndCompute($img, $mask);
  my ($kp, $desc) = $f2d->detectAndCompute($img);

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

=item
L<FastFeatureDetector()|http://docs.opencv.org/search.html?q=FastFeatureDetector>,
L<StarFeatureDetector()|http://docs.opencv.org/search.html?q=StarFeatureDetector>,
L<MserFeatureDetector()|http://docs.opencv.org/search.html?q=MserFeatureDetector>,
L<GoodFeaturesToTrackDetector()|http://docs.opencv.org/search.html?q=GoodFeaturesToTrackDetector>,
L<DenseFeatureDetector()|http://docs.opencv.org/search.html?q=DenseFeatureDetector>

  my $detector = FastFeatureDetector();
  my $detector = StarFeatureDetector();
  my $detector = MserFeatureDetector();
  my $detector = GoodFeaturesToTrackDetector();
  my $detector = DenseFeatureDetector();

=over

=item
L<detect()|http://docs.opencv.org/search.html?q=FeatureDetector::detect>

=back

  my $kp = $detector->detect($img, $mask);
  my $kp = $detector->detect($img);

=cut

{
	package Cv::Features2d::FeatureDetector;

	sub detect {
		if (ref $_[1] eq 'ARRAY') { goto &detect2 } else { goto &detect1 }
	}

	for (qw(FastFeatureDetector StarFeatureDetector MserFeatureDetector
		GoodFeaturesToTrackDetector DenseFeatureDetector)) {
		my $base = __PACKAGE__;
		eval "package ${base}::$_; our \@ISA = qw(${base})";
	}
}

=item
L<FREAK()|http://docs.opencv.org/search.html?q=FREAK>,
L<BriefDescriptorExtractor()|http://docs.opencv.org/search.html?q=BriefDescriptorExtractor>,
L<OpponentColorDescriptorExtractor()|http://docs.opencv.org/search.html?q=OpponentColorDescriptorExtractor>

  my $extractor = FREAK();
  my $extractor = BriefDescriptorExtractor();
  my $extractor = OpponentColorDescriptorExtractor("ORB"); # SIFT, SURF, ORB, BRISK, BRIEF

=over

=item
L<compute()|http://docs.opencv.org/search.html?q=DescriptorExtractor::compute>

=back

  my $desc = $extractor->compute($img, $kp);

=cut

{
	package Cv::Features2d::DescriptorExtractor::OpponentColorDescriptorExtractor;
	sub new {
		my ($class, $type) = @_;
		$type = (split('::', ref $type))[-1] if ref $type;
		$type =~ s/(^opponent|descriptorextractor$)//ig;
		$class->create(uc $type);
	}
}

{
	package Cv::Features2d::DescriptorExtractor;
	for (qw(BriefDescriptorExtractor FREAK OpponentColorDescriptorExtractor)) {
		my $base = __PACKAGE__;
		eval "package ${base}::$_; our \@ISA = qw(${base})";
	}
}

=item
L<BFMatcher()|http://docs.opencv.org/search.html?q=BFMatcher>

  my $matcher = BFMatcher();

=over

=item
L<match()|http://docs.opencv.org/search.html?q=DescriptorMatcher::match>,
L<knnMatch()|http://docs.opencv.org/search.html?q=DescriptorMatcher::knnMatch>,
L<radiusMatch()|http://docs.opencv.org/search.html?q=DescriptorMatcher::radiusMatch>

=back

  my $matches = $matcher->match($desc, $desc2, $mask);
  my $matches = $matcher->knnMatch($desc, $desc2, $k, $mask, $compact);
  my $matches = $matcher->radiusMatch($desc, $desc2, $maxDist, $mask, $compact);

=item
L<FlannBasedMatcher()|http://docs.opencv.org/search.html?q=FlannBasedMatcher>

  my $matcher = FlannBasedMatcher($indexParams, $searchParams);

The parameters are hashrefs as follows:

  my $matcher = FlannBasedMatcher(
    my $indexParams = {
      algorithm => 6,
      table_number => 6,
      key_size => 12,
      multi_probe_level => 1,
    });

To define SearchParams (one of IndexParams).

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

=item
L<drawKeypoints()|http://docs.opencv.org/search.html?q=drawKeypoints>,
L<drawMatches()|http://docs.opencv.org/search.html?q=drawMatches>

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
