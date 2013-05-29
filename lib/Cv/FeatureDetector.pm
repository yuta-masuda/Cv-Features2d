# -*- mode: perl; coding: utf-8; tab-width: 4; -*-

=encoding utf8

=head1 NAME

Cv::FeatureDetector - Cv extension for Features Detector

=head1 SYNOPSIS

  use Cv::FeatureDetector;
  
  my $mser = Cv->MSER();
  my $keypoints = $mser->detect($image, $mask);

=cut

package Cv::FeatureDetector;

use 5.008008;
use strict;
use warnings;
use Cv ();

our $VERSION = '0.28';

require XSLoader;
XSLoader::load('Cv::FeatureDetector', $VERSION);

require Exporter;

our @ISA = qw(Exporter);

our @EXPORT_OK = grep /^(IPL|CV|cv)/, (keys %Cv::FeatureDetector::);

our %EXPORT_TAGS = (
	'all' => \@EXPORT_OK,
	);

our @EXPORT = ( );

*AUTOLOAD = \&Cv::autoload;

package Cv::FeatureDetector::FAST;  our @ISA = qw(Cv::FeatureDetector);
package Cv::FeatureDetector::STAR;  our @ISA = qw(Cv::FeatureDetector);
package Cv::FeatureDetector::SIFT;  our @ISA = qw(Cv::FeatureDetector);
package Cv::FeatureDetector::SURF;  our @ISA = qw(Cv::FeatureDetector);
package Cv::FeatureDetector::ORB;   our @ISA = qw(Cv::FeatureDetector);
package Cv::FeatureDetector::BRISK; our @ISA = qw(Cv::FeatureDetector);
package Cv::FeatureDetector::MSER;  our @ISA = qw(Cv::FeatureDetector);
package Cv::FeatureDetector::Dense; our @ISA = qw(Cv::FeatureDetector);
package Cv::FeatureDetector::GFTT;  our @ISA = qw(Cv::FeatureDetector);

package Cv::FeatureDetector;

# ============================================================
#  features2d. Feature Detection and Description
# ============================================================

=head1 DESCRIPTION

=head2 METHOD

=over

=item new

  my $detector = Cv::FeatureDetector->new('FAST', ...);
  my $detector = Cv::FeatureDetector->new('STAR', ...);
  my $detector = Cv::FeatureDetector->new('SIFT', ...);
  my $detector = Cv::FeatureDetector->new('SURF', ...);
  my $detector = Cv::FeatureDetector->new('ORB', ...);
  my $detector = Cv::FeatureDetector->new('BRISK', ...);
  my $detector = Cv::FeatureDetector->new('MSER', ...);
  my $detector = Cv::FeatureDetector->new('Dense', ...);
  my $detector = Cv::FeatureDetector->new('GFTT', ...);
   or
  my $detector = Cv::FeatureDetector::FAST->new(...);
  my $detector = Cv::FeatureDetector::STAR->new(...);
  my $detector = Cv::FeatureDetector::SIFT->new(...);
  my $detector = Cv::FeatureDetector::SURF->new(...);
  my $detector = Cv::FeatureDetector::ORB->new(...);
  my $detector = Cv::FeatureDetector::BRISK->new(...);
  my $detector = Cv::FeatureDetector::MSER->new(...);
  my $detector = Cv::FeatureDetector::Dense->new(...);
  my $detector = Cv::FeatureDetector::GFTT->new(...);

=cut

sub new {
	join('::', splice(@_, 0, 2))->new(@_);
}

=item detect

  my @keypoints = $detector->detect($image);
  my @keypoints = $detector->detect($image, $mask);

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
