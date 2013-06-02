# -*- mode: perl; coding: utf-8; tab-width: 4; -*-

=encoding utf8

=head1 NAME

Cv::Features2d - Cv extension for Features Detector

=head1 SYNOPSIS

  use Cv::Features2d;
  use Cv::Features2d::FeatureDetector;
  
  my $surf = Cv::Features2d::SURF->new;
  my $keypoints = $surf->detect($image, $mask);
  drawKeypoints($image, $keypoints)->show;
  Cv->waitKey();

=cut

package Cv::Features2d;

use 5.008008;
use strict;
use warnings;
use Cv ();
use Cv::Features2d::FeatureDetector;
# use Cv::Features2d::DescriptorExtractor;
# use Cv::Features2d::DescriptorMatcher;

our $VERSION = '0.01';

require XSLoader;
XSLoader::load('Cv::Features2d', $VERSION);

require Exporter;

our @ISA = qw(Exporter);

our @EXPORT_OK = ( );
our %EXPORT_TAGS = ( 'all' => \@EXPORT_OK );
our @EXPORT = ( );

# ============================================================
#  features2d. Feature Detection and Description
# ============================================================

=head1 DESCRIPTION

=head2 METHOD

=over

=item drawKeypoints

  my $image = drawKeypoints($image, $keypoints, $color, $flags);

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
