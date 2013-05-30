# -*- mode: perl; coding: utf-8; tab-width: 4; -*-

=encoding utf8

=head1 NAME

Cv::Features2d::FeatureDetector - Cv extension for Features Detector

=head1 SYNOPSIS

  use Cv::Features2d::FeatureDetector;
  
  my $surf = Cv::Features2d::FeatureDetector::SURF->new;
  my $keypoints = $surf->detect($image, $mask);

=cut

package Cv::Features2d::FeatureDetector;

use 5.008008;
use strict;
use warnings;
use Cv ();
use Cv::Features2d;

our $VERSION = '0.01';

require Exporter;

our @ISA = qw(Exporter);

our @EXPORT_OK = ( );
our %EXPORT_TAGS = ( 'all' => \@EXPORT_OK );
our @EXPORT = ( );

package Cv::Features2d::FeatureDetector::FAST;
our @ISA = qw(Cv::Features2d::FeatureDetector);

package Cv::Features2d::FeatureDetector::STAR;
our @ISA = qw(Cv::Features2d::FeatureDetector);

package Cv::Features2d::FeatureDetector::SIFT;
our @ISA = qw(Cv::Features2d::FeatureDetector);

package Cv::Features2d::FeatureDetector::SURF;
our @ISA = qw(Cv::Features2d::FeatureDetector);

package Cv::Features2d::FeatureDetector::ORB;
our @ISA = qw(Cv::Features2d::FeatureDetector);

package Cv::Features2d::FeatureDetector::BRISK;
our @ISA = qw(Cv::Features2d::FeatureDetector);

package Cv::Features2d::FeatureDetector::MSER;
our @ISA = qw(Cv::Features2d::FeatureDetector);

package Cv::Features2d::FeatureDetector::GFTT;
our @ISA = qw(Cv::Features2d::FeatureDetector);

package Cv::Features2d::FeatureDetector::Dense;
our @ISA = qw(Cv::Features2d::FeatureDetector);


package Cv::Features2d::FeatureDetector;

# ============================================================
#  features2d. Feature Detection and Description
# ============================================================

=head1 DESCRIPTION

=head2 METHOD

=over

=item new

  my $detector = Cv::Features2d::FeatureDetector->new('FAST', ...);
  my $detector = Cv::Features2d::FeatureDetector->new('STAR', ...);
  my $detector = Cv::Features2d::FeatureDetector->new('SIFT', ...);
  my $detector = Cv::Features2d::FeatureDetector->new('SURF', ...);
  my $detector = Cv::Features2d::FeatureDetector->new('ORB', ...);
  my $detector = Cv::Features2d::FeatureDetector->new('BRISK', ...);
  my $detector = Cv::Features2d::FeatureDetector->new('MSER', ...);
  my $detector = Cv::Features2d::FeatureDetector->new('Dense', ...);
  my $detector = Cv::Features2d::FeatureDetector->new('GFTT', ...);
   or
  my $detector = Cv::Features2d::FeatureDetector::FAST->new(...);
  my $detector = Cv::Features2d::FeatureDetector::STAR->new(...);
  my $detector = Cv::Features2d::FeatureDetector::SIFT->new(...);
  my $detector = Cv::Features2d::FeatureDetector::SURF->new(...);
  my $detector = Cv::Features2d::FeatureDetector::ORB->new(...);
  my $detector = Cv::Features2d::FeatureDetector::BRISK->new(...);
  my $detector = Cv::Features2d::FeatureDetector::MSER->new(...);
  my $detector = Cv::Features2d::FeatureDetector::Dense->new(...);
  my $detector = Cv::Features2d::FeatureDetector::GFTT->new(...);

=cut

sub new {
	join('::', splice(@_, 0, 2))->new(@_);
}

=item detect

  my $keypoints = $detector->detect($image);
  my $keypoints = $detector->detect($image, $mask);

=cut

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
