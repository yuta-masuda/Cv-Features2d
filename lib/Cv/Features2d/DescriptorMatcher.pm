# -*- mode: perl; coding: utf-8; tab-width: 4; -*-

=encoding utf8

=head1 NAME

Cv::Features2d::DescriptorMatcher - Cv extension for Descriptor Matchers

=head1 SYNOPSIS

  use Cv::Features2d::DescriptorMatcher;

=cut

package Cv::Features2d::DescriptorMatcher;

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
#
# ============================================================

{
package Cv::Features2d::BFMatcher;
our @ISA = qw(Cv::Features2d::DescriptorMatcher);
}

# ============================================================
#  features2d. Feature Detection and Description
# ============================================================

=head1 DESCRIPTION

=head2 METHOD

=over

=item create

	my $descriptorMatcherType = "BruteForce";
	my $descriptorMatcherType = "BruteForce-L1";
	my $descriptorMatcherType = "BruteForce-Hamming";
	my $descriptorMatcherType = "BruteForce-Hamming(2)";
	my $descriptorMatcherType = "FlannBased";
	my $matcher = $class->create($descriptorMatcherType);

=item clone

	$matcher->clone($emptyTrainData);

=item clear

	$matcher->clear();

=item compute

	my $descriptor = $extractor->compute($image, $keypoints);

=item add

	$matcher->add($descriptors);

=item empty

	$matcher->empty();

=item getTrainDescriptors

	$matcher->getTrainDescriptors();

=item isMaskSupported

	$matcher->isMaskSupported();

=item train

	$matcher->train();

=item match

	my $matches = $matcher->match($queryDescriptors, $trainDescriptors, $mask);

=item knnMatch

	my $matches = $matcher->knnMatch($queryDescriptors, $trainDescriptors,
										$k, $mask, compactResult)

=item radiusMatch

	my $matches = $matcher->radiusMatch($queryDescriptors, $trainDescriptors,
										$maxDistance, $mask, $compactResult);

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
