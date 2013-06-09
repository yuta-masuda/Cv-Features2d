# -*- mode: perl; coding: utf-8; tab-width: 4; -*-

=encoding utf8

=head1 NAME

Cv::Features2d - Cv extension for OpenCV Features Detector

=head1 SYNOPSIS

  use Cv::Features2d qw(SURF drawKeypoints);
  
  my $surf = SURF(500);
  my $keypoints = $surf->detect($image);
  drawKeypoints($image, $keypoints);
  $image->show;
  Cv->waitKey();

=cut

package Cv::Features2d;

use 5.008008;
use strict;
use warnings;
use Cv ();
use Cv::Features2d::Feature2D;
use Cv::Features2d::FeatureDetector;
use Cv::Features2d::DescriptorExtractor;
use Cv::Features2d::DescriptorMatcher;

our $VERSION = '0.02';

require XSLoader;
XSLoader::load('Cv::Features2d', $VERSION);

require Exporter;

our @ISA = qw(Exporter);

our @EXPORT_OK = (qw(drawKeypoints SIFT SURF ORB BRISK BFMatcher FlannBasedMatcher));
our %EXPORT_TAGS = ( 'all' => \@EXPORT_OK );
our @EXPORT = ( );

{ package Cv::IndexParams; our $VERBOSE = 0 }

=head1 DESCRIPTION

=head2 METHOD

=over

=item SIFT, SURF, ORB, BRISK

  my $detector = SIFT();
  my $detector = SURF(500);
  my $detector = ORB();
  my $detector = BRISK();
  
  my ($kp1, $desc1) = $detector->detectAndCompute($img1);
  my ($kp2, $desc2) = $detector->detectAndCompute($img2, $mask2);

L<SIFT()|http://docs.opencv.org/search.html?q=SIFT>,
L<SURF()|http://docs.opencv.org/search.html?q=SURF>,
L<ORB()|http://docs.opencv.org/search.html?q=ORB>, and
L<BRISK()|http://docs.opencv.org/search.html?q=BRISK> are the
constructors defined in the class of Feature2D.  Please refer to the
OpenCV reference for more information.

=cut

sub SIFT  { Cv::Features2d::Feature2D::SIFT->new(@_) }
sub SURF  { Cv::Features2d::Feature2D::SURF->new(@_) }
sub ORB   { Cv::Features2d::Feature2D::ORB->new(@_) }
sub BRISK { Cv::Features2d::Feature2D::BRISK->new(@_) }

=item BFMatcher

  my $matcher = BFMatcher();
  my $dmatch = $matcher->knnMatch($desc1, $desc2, 2);

L<BFMatcher()|http://docs.opencv.org/search.html?q=BFMatcher> is a
constructor of Descriptor Matchers.

=item FlannBasedMatcher

  my $matcher = FlannBasedMatcher();
  my $matcher = FlannBasedMatcher($indexParams, $searchParams);

L<FlannBasedMatcher()|http://docs.opencv.org/search.html?q=FlannBasedMatcher>
is a also constructor.  The parameters are hashref as follows:

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
in the IndexParams is more detailed than Perl.  There are double,
float, int, bool, and string.  To clarify the type of them, you can
put the letter d/f/i/b for type after the name.

  letter  | type of IndexParams
 ------------------------------------
     d    |    double
     f    |    float
     i    |    int
     b    |    bool

If there is not type letter, the type of IndexParams is mapped from
sv-type.

  sv-type | type of IndexParams
 ------------------------------------
    NV    |    double
    IV    |    int
    PV    |    string

=cut

sub BFMatcher { Cv::Features2d::DescriptorMatcher::BFMatcher->new(@_) }
sub FlannBasedMatcher { Cv::Features2d::DescriptorMatcher::FlannBasedMatcher->new(@_) }

=item drawKeypoints

  drawKeypoints($image, $keypoints, $color, $flags);

=cut

*Cv::Arr::drawKeypoints = sub { drawKeypoints(@_); $_[0]; }; # XXXXX

=back

=cut

1;
__END__

=head2 EXPORT

None by default.


=head1 SEE ALSO

http://github.com/yuta-masuda/Cv-Feature2d


=head1 AUTHOR

MASUDA Yuta E<lt>yuta.cpan@gmail.comE<gt>


=head1 LICENCE

Copyright (c) 2013 by MASUDA Yuta.

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl itself.

=cut
