# -*- mode: perl; coding: utf-8; tab-width: 4; -*-

=encoding utf8

=head1 NAME

Cv::DescriptorExtractor - Cv extension for Features Detector

=head1 SYNOPSIS

  use Cv::FeatureDetector;
  use Cv::DescriptorExtractor;

=cut

package Cv::DescriptorExtractor;

use 5.008008;
use strict;
use warnings;
use Cv ();
use Cv::FeatureDetector;

our $VERSION = '0.28';

require Exporter;

our @ISA = qw(Exporter);

our @EXPORT_OK = ( );
our %EXPORT_TAGS = ( 'all' => \@EXPORT_OK );
our @EXPORT = ( );

# *AUTOLOAD = \&Cv::autoload;

package Cv::DescriptorExtractor::SIFT;  our @ISA = qw(Cv::DescriptorExtractor);
package Cv::DescriptorExtractor::SURF;  our @ISA = qw(Cv::DescriptorExtractor);
package Cv::DescriptorExtractor::ORB;   our @ISA = qw(Cv::DescriptorExtractor);
package Cv::DescriptorExtractor::BRISK; our @ISA = qw(Cv::DescriptorExtractor);
package Cv::DescriptorExtractor::BRIEF; our @ISA = qw(Cv::DescriptorExtractor);

package Cv::DescriptorExtractor;

# ============================================================
#  features2d. Feature Detection and Description
# ============================================================

=head1 DESCRIPTION

=head2 METHOD

=over

=item new

  my $detector = Cv::DescriptorExtractor->new('SIFT', ...);
  my $detector = Cv::DescriptorExtractor->new('SURF', ...);
  my $detector = Cv::DescriptorExtractor->new('ORB', ...);
  my $detector = Cv::DescriptorExtractor->new('BRISK', ...);
  my $detector = Cv::DescriptorExtractor->new('BRIEF', ...);
   or
  my $detector = Cv::DescriptorExtractor::SIFT->new(...);
  my $detector = Cv::DescriptorExtractor::SURF->new(...);
  my $detector = Cv::DescriptorExtractor::ORB->new(...);
  my $detector = Cv::DescriptorExtractor::BRISK->new(...);
  my $detector = Cv::DescriptorExtractor::BRIEF->new(...);

=cut

sub new {
	join('::', splice(@_, 0, 2))->new(@_);
}

=item compute

=cut

package Cv::DescriptorExtractor::SIFT;
sub new { __PACKAGE__->create("SIFT") }

package Cv::DescriptorExtractor::SURF;
sub new { __PACKAGE__->create("SURF") }

package Cv::DescriptorExtractor::ORB;
sub new { __PACKAGE__->create("OBB") }

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
