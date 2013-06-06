# -*- mode: perl; coding: utf-8; tab-width: 4; -*-

=encoding utf8

=head1 NAME

Cv::Features2d::DescriptorExtractor - Features2d.  Feature Detection
and Description

=head1 SYNOPSIS

=cut

package Cv::Features2d::Feature2D;

use 5.008008;
use strict;
use warnings;
use Cv ();
use Cv::Features2d::FeatureDetector;
use Cv::Features2d::DescriptorExtractor;

our $VERSION = '0.02';

our @ISA = qw(Cv::Features2d::FeatureDetector Cv::Features2d::DescriptorExtractor);

for (qw(SIFT SURF ORB BRISK)) {
	my $base = __PACKAGE__;
	eval "package ${base}::$_; our \@ISA = qw(${base})";
}

=head1 DESCRIPTION

=head2 METHOD

=over

=item detectAndCompute

  my ($keypoints, $descriptors) = $detector->detectAndCompute($image);
  my ($keypoints, $descriptors) = $detector->detectAndCompute($image, $mask);

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
