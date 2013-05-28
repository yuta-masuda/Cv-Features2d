# -*- mode: perl; coding: utf-8; tab-width: 4; -*-

=encoding utf8

=head1 NAME

Cv::Features2D::ORB - Cv extension for Features Detector

=head1 SYNOPSIS

  my $orb = Cv::Features2D:ORB->new;
  my $keypoints = $orb->detect($image);

=cut

package Cv::Features2D::ORB;

use 5.008008;
use strict;
use warnings;
use Cv ();

our $VERSION = '0.01';

require XSLoader;
XSLoader::load('Cv::Features2D::ORB', $VERSION);

require Exporter;

our @ISA = qw(Exporter);

our @EXPORT_OK = ();
our %EXPORT_TAGS = ( 'all' => [] );
our @EXPORT = ();

*AUTOLOAD = \&Cv::autoload;


=head1 DESCRIPTION

=head2 METHOD

=over

=item new

  my $orb = Cv::Features2D:ORB->new(500, 1.2, 8, ...);
  my $orb = Cv::Features2D:ORB->new(-nfeatures => 500, scaleFactor => 1.2, ...);

=item create

=cut

use constant kBytes => 32;
use constant HARRIS_SCORE => 0;
use constant FAST_SCORE => 0;

our @ORB = (
	nfeatures => 500,
	scaleFactor => 1.2,
	nlevels => 8,
	edgeThreshold => 31,
	firstLevel => 0,
	WTA_K => 2,
	scoreType => &HARRIS_SCORE,
	patchSize => 31,
	);

sub new {
	my $self = shift;
	my @template; my @keys;
	for (my $i = 0; $i < @ORB; $i += 2) {
		my ($k, $v) = @ORB[$i, $i + 1];
		$v = $self->{$k} if ref $self && defined $self->{$k};
		push(@keys, $k); push(@template, $k => $v);
	}
	$self->create(@{Cv::named_parameter(\@template, @_)}{@keys});
}

=item detect

  my $keypoints = $orb->detect($image, $mask);
  my ($keypoints, $descriptors) = $orb->detect($image, $mask);

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
