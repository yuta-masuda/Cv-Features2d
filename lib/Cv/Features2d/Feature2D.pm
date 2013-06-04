# -*- mode: perl; coding: utf-8; tab-width: 4; -*-

=encoding utf8

=head1 NAME

Cv::Features2d::DescriptorExtractor - Cv extension for Descriptor Extractors

=head1 SYNOPSIS

  use Cv::Features2d::DescriptorExtractor;

=cut

package Cv::Features2d::Feature2D;

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


# ============================================================
#  Feature Detection and Description
#    class SIFT: public Feature2D
#    class SURF: public Feature2D
#    class ORB: public Feature2D
#    class BRISK: public Feature2D
# ============================================================

{
	package Cv::Features2d::SIFT;  our @ISA = qw(Cv::Features2d::Feature2D);
	package Cv::Features2d::SURF;  our @ISA = qw(Cv::Features2d::Feature2D);
	package Cv::Features2d::ORB;   our @ISA = qw(Cv::Features2d::Feature2D);
	package Cv::Features2d::BRISK; our @ISA = qw(Cv::Features2d::Feature2D);
}

# ============================================================
#  features2d. Feature Detection and Description
# ============================================================

=head1 DESCRIPTION

=head2 METHOD

=over


=item new

=item create

TBD

=item detect

  my $keypoints = $detector->detect($image);
  my $keypoints = $detector->detect($image, $mask);

=item detectAndCompute

  my ($keypoints, $descriptors) = $detector->detectAndCompute($image);
  my ($keypoints, $descriptors) = $detector->detectAndCompute($image, $mask);

=item compute

  my $descriptor = $extractor->compute($image, $keypoints);

=item descriptorSize

  my $size = $extractor->descriptorSize();

=item descriptorType

  my $type = $extractor->descriptorType();

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
