# -*- mode: perl; coding: utf-8; tab-width: 4; -*-

=encoding utf8

=head1 NAME

Cv::Features2d - Cv extension for Features Detector

=head1 SYNOPSIS

  use Cv::Features2d qw(SURF drawKeypoints);
  
  my $surf = SURF(500);
  my $keypoints = $surf->detect($image);
  drawKeypoints($image, $keypoints)->show;
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

our $VERSION = '0.01';

require XSLoader;
XSLoader::load('Cv::Features2d', $VERSION);

require Exporter;

our @ISA = qw(Exporter);

our @EXPORT_OK = (qw(drawKeypoints SIFT SURF ORB BRISK BFMatcher));
our %EXPORT_TAGS = ( 'all' => \@EXPORT_OK );
our @EXPORT = ( );

=head1 DESCRIPTION

=head2 METHOD

=over

=item SIFT, SURF, ORB, BRISK

  my $detector = SIFT();
    or
  my $detector = SURF(500);
  my $detector = ORB();
  my $detector = BRISK();
  
  my ($kp1, $desc1) = $detector->detectAndCompute($img1);
  my ($kp2, $desc2) = $detector->detectAndCompute($img2);

L<SIFT()|http://docs.opencv.org/search.html?q=SIFT>,
L<SURF()|http://docs.opencv.org/search.html?q=SURF>,
L<ORB()|http://docs.opencv.org/search.html?q=ORB>,
L<BRISK()|http://docs.opencv.org/search.html?q=BRISK>,
...

=cut

sub SIFT  { Cv::Features2d::SIFT->new(@_) }
sub SURF  { Cv::Features2d::SURF->new(@_) }
sub ORB   { Cv::Features2d::ORB->new(@_) }
sub BRISK { Cv::Features2d::BRISK->new(@_) }

=item BFMatcher

  my $matcher = BFMatcher();
  my $dmatch = $matcher->knnMatch($desc1, $desc2, 2);

see sample/find_obj.pl

L<BFMatcher()|http://docs.opencv.org/search.html?q=BFMatcher>,
...

=cut

sub BFMatcher { Cv::Features2d::BFMatcher->new(@_) }

=item drawKeypoints

  my $image = drawKeypoints($image, $keypoints, $color, $flags);

=back

=cut

1;
__END__

=head2 EXPORT

None by default.


=head1 SEE ALSO

http://github.com/obuk/Cv-Olive

=head1 AUTHOR

MASUDA Yuta E<lt>yuta.cpan@gmail.comE<gt>


=head1 LICENCE

Copyright (c) 2013 by MASUDA Yuta.

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl itself.

=cut
