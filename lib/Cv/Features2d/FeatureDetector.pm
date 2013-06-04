# -*- mode: perl; coding: utf-8; tab-width: 4; -*-

=encoding utf8

=head1 NAME

Cv::Features2d::FeatureDetector - Cv extension for Feature Detectors

=head1 SYNOPSIS

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


# ============================================================
#  Common Interfaces of Feature Detectors
#    class FastFeatureDetector: public FeatureDetector
#    class StarFeatureDetector: public FeatureDetector
#    class MSER: public FeatureDetector
#    class MserFeatureDetector : public FeatureDetector
#    class GoodFeaturesToTrackDetector: public FeatureDetector
#    class DenseFeatureDetector: public FeatureDetector
#    class SimpleBlobDetector: public FeatureDetector
# ============================================================

{
package Cv::Features2d::FastFeatureDetector;
our @ISA = qw(Cv::Features2d::FeatureDetector);

package Cv::Features2d::StarFeatureDetector;
our @ISA = qw(Cv::Features2d::FeatureDetector);

package Cv::Features2d::MSER;
our @ISA = qw(Cv::Features2d::FeatureDetector);

package Cv::Features2d::MserFeatureDetector;
our @ISA = qw(Cv::Features2d::FeatureDetector);

package Cv::Features2d::GoodFeaturesToTrackDetector;
our @ISA = qw(Cv::Features2d::FeatureDetector);

package Cv::Features2d::DenseFeatureDetector;
our @ISA = qw(Cv::Features2d::FeatureDetector);

package Cv::Features2d::SimpleBlobDetector;
our @ISA = qw(Cv::Features2d::FeatureDetector);

package Cv::Features2d::FAST;
our @ISA = qw(Cv::Features2d::FeatureDetector);
}

=head1 DESCRIPTION

=head2 METHOD

=over

=item new

=item create

TBD

=item detect

  my $keypoints = $detector->detect($image);
  my $keypoints = $detector->detect($image, $mask);

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
