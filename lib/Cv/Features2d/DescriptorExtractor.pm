# -*- mode: perl; coding: utf-8; tab-width: 4; -*-

=encoding utf8

=head1 NAME

Cv::Features2d::DescriptorExtractor - Cv extension for Features Detector

=head1 SYNOPSIS

  use Cv::Features2d::DescriptorExtractor;

=cut

package Cv::Features2d::DescriptorExtractor;

use 5.008008;
use strict;
use warnings;
use Cv ();
use Cv::Features2d;
use Cv::Features2d::FeatureDetector;

our $VERSION = '0.01';

require Exporter;

our @ISA = qw(Exporter);

our @EXPORT_OK = ( );
our %EXPORT_TAGS = ( 'all' => \@EXPORT_OK );
our @EXPORT = ( );

package Cv::Features2d::DescriptorExtractor::SIFT;
our @ISA = qw(Cv::Features2d::DescriptorExtractor);

package Cv::Features2d::DescriptorExtractor::SURF;
our @ISA = qw(Cv::Features2d::DescriptorExtractor);

package Cv::Features2d::DescriptorExtractor::ORB;
our @ISA = qw(Cv::Features2d::DescriptorExtractor);

package Cv::Features2d::DescriptorExtractor::BRISK;
our @ISA = qw(Cv::Features2d::DescriptorExtractor);

package Cv::Features2d::DescriptorExtractor::BRIEF;
our @ISA = qw(Cv::Features2d::DescriptorExtractor);

package Cv::Features2d::DescriptorExtractor;

# ============================================================
#  features2d. Feature Detection and Description
# ============================================================

=head1 DESCRIPTION

=head2 METHOD

=over

=item new

  my $detector = Cv::Features2d::DescriptorExtractor->new('SIFT');
  my $detector = Cv::Features2d::DescriptorExtractor->new('SURF');
  my $detector = Cv::Features2d::DescriptorExtractor->new('ORB');
  my $detector = Cv::Features2d::DescriptorExtractor->new('BRISK');
  my $detector = Cv::Features2d::DescriptorExtractor->new('BRIEF');
   or
  my $detector = Cv::Features2d::DescriptorExtractor::SIFT->new;
  my $detector = Cv::Features2d::DescriptorExtractor::SURF->new;
  my $detector = Cv::Features2d::DescriptorExtractor::ORB->new;
  my $detector = Cv::Features2d::DescriptorExtractor::BRISK->new;
  my $detector = Cv::Features2d::DescriptorExtractor::BRIEF->new;

=cut

sub new {
	join('::', splice(@_, 0, 2))->new(@_);
}


=item create

	my $extractor = $class->create($descriptorExtractorType);

=cut

sub Cv::DescriptorExtractor::SIFT::new  { shift->SUPER::create("SIFT")  }
sub Cv::DescriptorExtractor::SURF::new  { shift->SUPER::create("SURF")  }
sub Cv::DescriptorExtractor::ORB::new   { shift->SUPER::create("ORB")   }
sub Cv::DescriptorExtractor::BRISK::new { shift->SUPER::create("BRISK") }


=item compute

	my $descriptor = $extractor->compute($image, $keypoints);

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
