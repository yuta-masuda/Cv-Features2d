# -*- mode: perl; coding: utf-8; tab-width: 4; -*-

=encoding utf8

=head1 NAME

Cv::Features2d::FeatureDetector - Features2d. Common Interfaces of
Feature Detectors

=head1 SYNOPSIS

=cut

package Cv::Features2d::FeatureDetector;

use 5.008008;
use strict;
use warnings;
use Cv ();
use Cv::Features2d;

our $VERSION = '0.01';

for (qw(FastFeatureDetector StarFeatureDetector MserFeatureDetector
		GoodFeaturesToTrackDetector DenseFeatureDetector)) {
	my $base = 'Cv::Features2d';
	eval "package ${base}::$_; our \@ISA = qw(${base}::FeatureDetector)";
}

=head1 DESCRIPTION

=head2 METHOD

=over

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
