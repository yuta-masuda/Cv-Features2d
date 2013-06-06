# -*- mode: perl; coding: utf-8; tab-width: 4; -*-

=encoding utf8

=head1 NAME

Cv::Features2d::DescriptorExtractor - Features2d.  Common Interfaces
of Descriptor Extractors

=head1 SYNOPSIS

=cut

package Cv::Features2d::DescriptorExtractor;

use 5.008008;
use strict;
use warnings;
use Cv ();
use Cv::Features2d;

our $VERSION = '0.02';

for (qw(BriefDescriptorExtractor)) {
	my $base = __PACKAGE__;
	eval "package ${base}::$_; our \@ISA = qw(${base})";
}

=head1 DESCRIPTION

=head2 METHOD

=over

=item compute

  my $descriptor = $extractor->compute($image, $keypoints);

=item descriptorSize

  my $size = $extractor->descriptorSize();

=item descriptorType

  my $type = $extractor->descriptorType();

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
