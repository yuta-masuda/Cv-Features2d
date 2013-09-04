# -*- mode: perl; coding: utf-8; tab-width: 4; -*-

=encoding utf8

=head1 NAME

Cv::Features2d - Cv extension for OpenCV Feature Detector

=head1 SYNOPSIS

  use Cv::Features2d qw(SURF drawKeypoints);
  my $gray = Cv->loadImage(shift, CV_LOAD_IMAGE_GRAYSCALE);
  my $surf = SURF(500);
  my $keypoints = $surf->detect($gray);
  my $color = $gray->cvtColor(CV_GRAY2BGR);
  drawKeypoints($color, $keypoints);
  $color->show;
  Cv->waitKey;

=cut

package Cv::Features2d;

use 5.008009;
use strict;
use warnings;
use Carp;
use Data::Structure::Util qw(unbless);
use Cv ();

our $VERSION = '0.09';

require XSLoader;
XSLoader::load('Cv::Features2d', $VERSION);

require Exporter;

our @ISA = qw(Exporter);

our @EXPORT_OK = (qw(drawKeypoints drawMatches),
				  qw(PyramidAdaptedFeatureDetector),
				  qw(OpponentColorDescriptorExtractor),
				  qw(DynamicAdaptedFeatureDetector),
	);
our %EXPORT_TAGS = ( 'all' => \@EXPORT_OK );
our @EXPORT = ( );

our %CLASS;

for (classes(__PACKAGE__)) {
	if ($_->can('new')) {
		my $name = (split('::', $_))[-1];
		unless (__PACKAGE__->can($name)) {
			# warn "sub $name { ${_}->new(\@_) }", "\n";
			eval "sub $name { ${_}->new(\@_) }";
			push(@EXPORT_OK, $name);
		}
	}
}

sub classes {
	my @list = ();
	for my $base (@_) {
		for (keys %{eval "\\%${base}::"}) {
			if (/^(\w+)::$/) {
				push(@list, &classes("${base}::$1"));
			}
		}
		push(@list, $base);
	}
	@list;
}

=head1 DESCRIPTION

=cut

#  core. Basic Structures: Algorithm

{
	package Cv::Features2d::Algorithm;
	require Exporter;
	our @ISA = qw(Exporter);
	our @EXPORT_OK = (qw(Int Bool Double Algorithm));
	sub Double {
		local $Carp::CarpLevel = $Carp::CarpLevel + 2;
		my $self = shift;
		(my $name = (caller 1)[3]) =~ s/.*:://;
		my $RETVAL = $self->get_double($name);
		$self->set_double($name, $_[0]) if defined $_[0];
		$RETVAL;
	}
	sub Int {
		local $Carp::CarpLevel = $Carp::CarpLevel + 2;
		my $self = shift;
		(my $name = (caller 1)[3]) =~ s/.*:://;
		my $RETVAL = $self->get_int($name);
		$self->set_int($name, $_[0]) if defined $_[0];
		$RETVAL;
	}
	sub Bool {
		local $Carp::CarpLevel = $Carp::CarpLevel + 2;
		my $self = shift;
		(my $name = (caller 1)[3]) =~ s/.*:://;
		my $RETVAL = $self->get_bool($name);
		$self->set_bool($name, $_[0]) if defined $_[0];
		$RETVAL;
	}
	sub Algorithm {
		local $Carp::CarpLevel = $Carp::CarpLevel + 2;
		my $self = shift;
		(my $name = (caller 1)[3]) =~ s/.*:://;
		my $RETVAL = $self->get_algorithm($name);
		if (my $algorithm = Cv::Features2d::Algorithm::name($RETVAL)) {
			if (my $class = $Cv::Features2d::CLASS{$algorithm}) {
				bless $RETVAL, "${class}::Ghost";
			}
		}
		# can't call set_algorithm; - makes memory leak
		# $self->set_algorithm($name, $_[0]) if defined $_[0];
		$RETVAL;
	}
}


# @ISAs of the Cv::Features2d

{
	package Cv::Features2d::FeatureDetector;
	our @ISA = qw(Cv::Features2d::Algorithm);
	package Cv::Features2d::DescriptorExtractor;
	our @ISA = qw(Cv::Features2d::Algorithm);
	package Cv::Features2d::Feature2D;
	our @ISA = qw(Cv::Features2d::FeatureDetector Cv::Features2d::DescriptorExtractor);
	package Cv::Features2d::DescriptorMatcher;
	our @ISA = qw(Cv::Features2d::Algorithm);
}


=head2 Feature2D

There are constructors for extracting keypoints and computing
descriptors.

=over

=item
L<ORB()|http://docs.opencv.org/search.html?q=ORB>

=cut

{
	package Cv::Features2d::ORB;
	use constant { kBytes => 32, HARRIS_SCORE => 0, FAST_SCORE => 1 };
	our @ISA = qw(Cv::Features2d::Feature2D);
	$Cv::Features2d::CLASS{ 'Feature2D.ORB' } = __PACKAGE__;
	sub new {
		my ($class, $nFeatures, $scaleFactor, $nLevels,
			$edgeThreshold, $firstLevel, $WTA_K, $scoreType,
			$patchSize) = @_;
		if (ref $class) {
			$nFeatures = $class->nFeatures
				unless defined $nFeatures;
			$scaleFactor = $class->scaleFactor
				unless defined $scaleFactor;
			$nLevels = $class->nLevels
				unless defined $nLevels;
			$edgeThreshold = $class->edgeThreshold
				unless defined $edgeThreshold;
			$firstLevel = $class->firstLevel
				unless defined $firstLevel;
			$WTA_K = $class->WTA_K
				unless defined $WTA_K;
			$scoreType = $class->scoreType
				unless defined $scoreType;
			$patchSize = $class->patchSize
				unless defined $patchSize;
		}
		my $self = bless $class->create("ORB");
		$self->nFeatures($nFeatures || 500);
		$self->scaleFactor($scaleFactor || 1.2);
		$self->nLevels($nLevels || 8);
		$self->edgeThreshold($edgeThreshold || 31);
		$self->firstLevel($firstLevel || 0);
		$self->WTA_K($WTA_K || 2);
		$self->scoreType($scoreType || HARRIS_SCORE);
		$self->patchSize($patchSize || 31);
		$self;
	}
}

=item
L<BRISK()|http://docs.opencv.org/search.html?q=BRISK>

=cut

{
	package Cv::Features2d::BRISK;
	our @ISA = qw(Cv::Features2d::Feature2D);
	$Cv::Features2d::CLASS{ 'Feature2D.BRISK' } = __PACKAGE__;
}

=item
L<SIFT()|http://docs.opencv.org/search.html?q=SIFT>

=cut

{
	package Cv::Features2d::SIFT;
	our @ISA = qw(Cv::Features2d::Feature2D);
	$Cv::Features2d::CLASS{ 'Feature2D.SIFT' } = __PACKAGE__;
	sub new {
		my ($class, $nFeatures, $nOctaveLayers, $contrastThreshold,
			$edgeThreshold, $sigma) = @_;
		if (ref $class) {
			$nFeatures = $class->nFeatures
				unless defined $nFeatures;
			$nOctaveLayers = $class->nOctaveLayers
				unless defined $nOctaveLayers;
			$contrastThreshold = $class->contrastThreshold
				unless defined $contrastThreshold;
			$edgeThreshold = $class->edgeThreshold
				unless defined $edgeThreshold;
			$sigma = $class->sigma
				unless defined $sigma;
		}
		my $self = bless $class->create("SIFT");
		$self->nFeatures($nFeatures || 0);
		$self->nOctaveLayers($nOctaveLayers || 3);
		$self->contrastThreshold($contrastThreshold || 0.04);
		$self->edgeThreshold($edgeThreshold || 10);
		$self->sigma($sigma || 1.6);
		$self;
	}
}

=item
L<SURF()|http://docs.opencv.org/search.html?q=SURF>

=cut

{
	package Cv::Features2d::SURF;
	our @ISA = qw(Cv::Features2d::Feature2D);
	$Cv::Features2d::CLASS{ 'Feature2D.SURF' } = __PACKAGE__;
	sub new {
		my ($class, $hessianThreshold, $nOctaves, $nOctaveLayers,
			$extended, $upright) = @_;
		if (ref $class) {
			$hessianThreshold = $class->hessianThreshold
				unless defined $hessianThreshold;
			$nOctaves = $class->nOctaves
				unless defined $nOctaves;
			$nOctaveLayers = $class->nOctaveLayers
				unless defined $nOctaveLayers;
			$extended = $class->extended
				unless defined $extended;
			$upright = $class->upright
				unless defined $upright;
		}
		my $self = bless $class->create("SURF");
		$self->hessianThreshold($hessianThreshold);
		$self->nOctaves($nOctaves || 4);
		$self->nOctaveLayers($nOctaveLayers || 2);
		$self->extended($extended || 1);
		$self->upright($upright || 0);
		$self;
	}
	sub copy {
		my ($self, $copy) = @_;
		$copy->hessianThreshold($self->hessianThreshold);
		$copy->nOctaves($self->nOctaves);
		$copy->nOctaveLayers($self->nOctaveLayers);
		$copy->extended($self->extended);
		$copy->upright($self->upright);
		$copy;
	}
}

=back

  my $orb = ORB();
  my $brisk = BRISK();
  my $sift = SIFT();
  my $surf = SURF(200);

The object has methods detect(), compute(), and detectAndCompute().

=over

=item
L<detectAndCompute()|http://docs.opencv.org/search.html?q=detectAndCompute>

=back

  my ($kp, $desc) = $surf->detectAndCompute($img, $mask);
  my ($kp, $desc) = $surf->detectAndCompute($img);

Parameters of the constructor can also be set/get as properties of the
object.

  my $hessianThreshold = $surf->hessianThreshold;
  $surf->hessianThreshold(200);

=over

=item *
L</ORB()> - nFeatures, scaleFactor, nLevels, edgeThreshold,
firstLevel, WTA_K, scoreType, patchSize

=cut

{
	package Cv::Features2d::ORB;
	Cv::Features2d::Algorithm->import(qw(Int Double));
	sub nFeatures { &Int }
	sub scaleFactor { &Double }
	sub nLevels { &Int }
	sub edgeThreshold { &Int }
	sub firstLevel { &Int }
	sub WTA_K { &Int }
	sub scoreType { &Int }
	sub patchSize { &Int }
}

=item *
L</BRISK()> - thres, octaves

=cut

{
	package Cv::Features2d::BRISK;
	Cv::Features2d::Algorithm->import(qw(Int Double));
	sub thres { &Int }
	sub octaves { &Int }
}

=item *
L</SIFT()> - nFeatures, nOctaveLayers, contrastThreshold,
edgeThreshold, sigma

=cut

{
	package Cv::Features2d::SIFT;
	Cv::Features2d::Algorithm->import(qw(Int Double));
	sub nFeatures { &Int }
	sub nOctaveLayers { &Int }
	sub contrastThreshold { &Double }
	sub edgeThreshold { &Double }
	sub sigma { &Double }
}

=item *
L</SURF()> - hessianThreshold, nOctaves, nOctaveLayers,
extended, upright

=cut

{
	package Cv::Features2d::SURF;
	Cv::Features2d::Algorithm->import(qw(Int Double Bool));
	sub hessianThreshold { &Double }
	sub nOctaves { &Int }
	sub nOctaveLayers { &Int }
	sub extended { &Bool }
	sub upright { &Bool }
}

=back

=head2 FeatureDetector

=over

=item
L<FastFeatureDetector()|http://docs.opencv.org/search.html?q=FastFeatureDetector>

=cut

{
	package Cv::Features2d::FastFeatureDetector;
	our @ISA = qw(Cv::Features2d::FeatureDetector);
	$Cv::Features2d::CLASS{ 'Feature2D.FAST' } = __PACKAGE__;
	sub new {
		my ($class, $threshold, $nonmaxSuppression) = @_;
		if (ref $class) {
			$threshold = $class->threshold
				unless defined $threshold;
			$nonmaxSuppression = $class->nonmaxSuppression
				unless defined $nonmaxSuppression;
		}
		my $self = bless $class->create("FAST");
		$self->threshold($threshold || 1);
		$self->nonmaxSuppression($nonmaxSuppression || 1);
		$self;
	}
	sub copy {
		my ($self, $copy) = @_;
		$copy->threshold($self->threshold);
		$copy->nonmaxSuppression($self->nonmaxSuppression);
		$copy;
	}
}

=item
L<StarFeatureDetector()|http://docs.opencv.org/search.html?q=StarFeatureDetector>

=cut

{
	package Cv::Features2d::StarFeatureDetector;
	our @ISA = qw(Cv::Features2d::FeatureDetector);
	$Cv::Features2d::CLASS{ 'Feature2D.STAR' } = __PACKAGE__;
	sub new {
		my ($class, $maxSize, $responseThreshold,
			$lineThresholdProjected, $lineThresholdBinarized,
			$suppressNonmaxSize) = @_;
		if (ref $class) {
			$maxSize = $class->maxSize
				unless defined $maxSize;
			$responseThreshold = $class->responseThreshold
				unless defined $responseThreshold;
			$lineThresholdProjected = $class->lineThresholdProjected
				unless defined $lineThresholdProjected;
			$lineThresholdBinarized = $class->lineThresholdBinarized
				unless defined $lineThresholdBinarized;
			$suppressNonmaxSize = $class->suppressNonmaxSize
				unless defined $suppressNonmaxSize;
		}
		my $self = bless $class->create("STAR");
		$self->maxSize($maxSize || 16);
		$self->responseThreshold($responseThreshold || 30);
		$self->lineThresholdProjected($lineThresholdProjected || 10);
		$self->lineThresholdBinarized($lineThresholdBinarized || 8);
		$self->suppressNonmaxSize($suppressNonmaxSize || 5);
		$self;
	}
	sub copy {
		my ($self, $copy) = @_;
		$copy->maxSize($self->maxSize);
		$copy->responseThreshold($self->responseThreshold);
		$copy->lineThresholdProjected($self->lineThresholdProjected);
		$copy->lineThresholdBinarized($self->lineThresholdBinarized);
		$copy->suppressNonmaxSize($self->suppressNonmaxSize);
		$copy;
	}
}



=item
L<MserFeatureDetector()|http://docs.opencv.org/search.html?q=MserFeatureDetector>

=cut

{
	package Cv::Features2d::MserFeatureDetector;
	our @ISA = qw(Cv::Features2d::FeatureDetector);
	$Cv::Features2d::CLASS{ 'Feature2D.MSER' } = __PACKAGE__;
	sub new {
		my ($class, $delta, $minArea, $maxArea, $maxVariation,
			$minDiversity, $maxEvolution, $areaThreshold, $minMargin,
			$edgeBlurSize) = @_;
		if (ref $class) {
			$delta = $class->delta
				unless defined $delta;
			$minArea = $class->minArea
				unless defined $minArea;
			$maxArea = $class->maxArea
				unless defined $maxArea;
			$maxVariation = $class->maxVariation
				unless defined $maxVariation;
			$minDiversity = $class->minDiversity
				unless defined $minDiversity;
			$maxEvolution = $class->maxEvolution
				unless defined $maxEvolution;
			$areaThreshold = $class->areaThreshold
				unless defined $areaThreshold;
			$minMargin = $class->minMargin
				unless defined $minMargin;
			$edgeBlurSize = $class->edgeBlurSize
				unless defined $edgeBlurSize;
		}
		my $self = bless $class->create("MSER");
		$self->delta($delta);
		$self->minArea($minArea);
		$self->maxArea($maxArea);
		$self->maxVariation($maxVariation);
		$self->minDiversity($minDiversity);
		$self->maxEvolution($maxEvolution);
		$self->areaThreshold($areaThreshold);
		$self->minMargin($minMargin);
		$self->edgeBlurSize($edgeBlurSize);
		$self;
	}
}

=item
L<GoodFeaturesToTrackDetector()|http://docs.opencv.org/search.html?q=GoodFeaturesToTrackDetector>

=cut

{
	package Cv::Features2d::GoodFeaturesToTrackDetector;
	our @ISA = qw(Cv::Features2d::FeatureDetector);
	$Cv::Features2d::CLASS{ "Feature2D.GFTT" } = __PACKAGE__;
}

=item
L<DenseFeatureDetector()|http://docs.opencv.org/search.html?q=DenseFeatureDetector>

=cut

{
	package Cv::Features2d::DenseFeatureDetector;
	our @ISA = qw(Cv::Features2d::FeatureDetector);
	$Cv::Features2d::CLASS{ 'Feature2D.Dense' } = __PACKAGE__;
	sub new {
		my ($class, $initFeatureScale, $featureScaleLevels,
			$featureScaleMul, $initXyStep, $initImgBound,
			$varyXyStepWithScale, $varyImgBoundWithScale) = @_;
		if (ref $class) {
			$initFeatureScale = $class->initFeatureScale
				unless defined $initFeatureScale;
			$featureScaleLevels = $class->featureScaleLevels
				unless defined $featureScaleLevels;
			$featureScaleMul = $class->featureScaleMul
				unless defined $featureScaleMul;
			$initXyStep = $class->initXyStep
				unless defined $initXyStep;
			$initImgBound = $class->initImgBound
				unless defined $initImgBound;
			$varyXyStepWithScale = $class->varyXyStepWithScale
				unless defined $varyXyStepWithScale;
			$varyImgBoundWithScale = $class->varyImgBoundWithScale
				unless defined $varyImgBoundWithScale;
		}
		my $self = bless $class->create("Dense");
		$self->initFeatureScale($initFeatureScale || 1);
		$self->featureScaleLevels($featureScaleLevels || 1);
		$self->featureScaleMul($featureScaleMul || 0.1);
		$self->initXyStep($initXyStep || 6);
		$self->initImgBound($initImgBound || 0);
		$self->varyXyStepWithScale($varyXyStepWithScale || 1);
		$self->varyImgBoundWithScale($varyImgBoundWithScale || 0);
		$self;
	}
}

=item
L<SimpleBlobDetector()|http://docs.opencv.org/search.html?q=SimpleBlobDetector>

=cut

{
	package Cv::Features2d::SimpleBlobDetector;
	our @ISA = qw(Cv::Features2d::FeatureDetector);
	$Cv::Features2d::CLASS{ 'Feature2D.SimpleBlob' } = __PACKAGE__;
	sub new {
		my $class = shift;
		my $self = bless $class->create("SimpleBlob");
		if (ref $class) {
			$self->thresholdStep($class->thresholdStep);
			$self->minThreshold($class->minThreshold);
			$self->maxThreshold($class->maxThreshold);
			$self->minRepeatability($class->minRepeatability);
			$self->minDistBetweenBlobs($class->minDistBetweenBlobs);
			$self->filterByColor($class->filterByColor);
			# $self->blobColor($class->blobColor);
			$self->filterByArea($class->filterByArea);
			$self->maxArea($class->maxArea);
			$self->filterByCircularity($class->filterByCircularity);
			$self->maxCircularity($class->maxCircularity);
			$self->filterByInertia($class->filterByInertia);
			$self->maxInertiaRatio($class->maxInertiaRatio);
			$self->filterByConvexity($class->filterByConvexity);
			$self->maxConvexity($class->maxConvexity);
		}
		$self;
	}
}

=item
L<GridAdaptedFeatureDetector()|http://docs.opencv.org/search.html?q=GridAdaptedFeatureDetector>

=cut

{
	package Cv::Features2d::GridAdaptedFeatureDetector;
	our @ISA = qw(Cv::Features2d::FeatureDetector);
	$Cv::Features2d::CLASS{ 'Feature2D.Grid' } = __PACKAGE__;
	sub new {
		my ($class, $detector, $maxTotalKeypoints, $gridRows,
			$gridCols) = @_;
		if (ref $class) {
			$detector = $class->detector
				unless defined $detector;
			$maxTotalKeypoints = $class->maxTotalKeypoints
				unless defined $maxTotalKeypoints;
			$gridRows = $class->gridRows
				unless defined $gridRows;
			$gridCols = $class->gridCols
				unless defined $gridCols;
		}
		my $detectorType = ref $detector?
			(split(/\./, $detector->name))[-1] : $detector;
		my $self = bless $class->create("Grid$detectorType");
		if ($self) {
			if (ref $detector && $detector->can('copy')) {
				$detector->copy($self->detector());
			}
			$self->maxTotalKeypoints($maxTotalKeypoints);
			$self->gridRows($gridRows || 4);
			$self->gridCols($gridCols || 4);
		}
		$self;
	}
}

=item
L<PyramidAdaptedFeatureDetector()|http://docs.opencv.org/search.html?q=PyramidAdaptedFeatureDetector>

=cut

{
	package Cv::Features2d::PyramidAdaptedFeatureDetector;
	our @ISA = qw(Cv::Features2d::FeatureDetector);
}

sub PyramidAdaptedFeatureDetector {
	my $detector = shift;
	return undef unless ref $detector &&
		$detector->name =~ /Feature2D\.(SURF|FAST|STAR|SIFT)/;
	my $ptr = unbless $detector->new();
	Cv::Features2d::PyramidAdaptedFeatureDetector->new($ptr, @_);
}

=item
L<DynamicAdaptedFeatureDetector()|http://docs.opencv.org/search.html?q=DynamicAdaptedFeatureDetector>

=cut

{
	package Cv::Features2d::DynamicAdaptedFeatureDetector;
	our @ISA = qw(Cv::Features2d::FeatureDetector);
}

sub DynamicAdaptedFeatureDetector {
	my $adapter = shift;
	my $ptr = unbless $adapter->new();
	Cv::Features2d::DynamicAdaptedFeatureDetector->new($ptr, @_);
}

=back

  my $detector = FastFeatureDetector();
  my $detector = StarFeatureDetector();
  my $detector = MserFeatureDetector();
  my $detector = GoodFeaturesToTrackDetector();
  my $detector = DenseFeatureDetector();
  my $detector = GridAdaptedFeatureDetector(FastFeatureDetector(), 500);
  my $detector = PyramidAdaptedFeatureDetector(FastFeatureDetector());

=over

=item
L<detect()|http://docs.opencv.org/search.html?q=FeatureDetector::detect>

=back

  my $kp = $detector->detect($img, $mask);
  my $kp = $detector->detect($img);

properties are:

=over

=item *
L</FastFeatureDetector()> - threshold, nonmaxSuppression

=cut

{
	package Cv::Features2d::FastFeatureDetector;
	Cv::Features2d::Algorithm->import(qw(Int Bool));
	sub threshold { &Int }
	sub nonmaxSuppression { &Bool }
}

=item *
L</StarFeatureDetector()> - maxSize, responseThreshold, lineThresholdProjected,
lineThresholdBinarized, suppressNonmaxSize

=cut

{
	package Cv::Features2d::StarFeatureDetector;
	Cv::Features2d::Algorithm->import(qw(Int));
	sub maxSize { &Int }
	sub responseThreshold { &Int }
	sub lineThresholdProjected { &Int }
	sub lineThresholdBinarized { &Int }
	sub suppressNonmaxSize { &Int }
}

=item *
L</MserFeatureDetector()> - delta, minArea, maxArea, maxVariation,
minDiversity, maxEvolution, minMargin, edgeBlurSize

=cut

{
	package Cv::Features2d::MserFeatureDetector;
	Cv::Features2d::Algorithm->import(qw(Int Double));
	sub delta { &Int }
	sub minArea { &Int }
	sub maxArea { &Int }
	sub maxVariation { &Double }
	sub minDiversity { &Double }
	sub maxEvolution { &Int }
	sub areaThreshold { &Double }
	sub minMargin { &Double }
	sub edgeBlurSize { &Int }
}

=item *
L</GoodFeaturesToTrackDetector()> - nfeatures, qualityLevel, minDistance,
useHarrisDetector, k

=cut

{
	package Cv::Features2d::GoodFeaturesToTrackDetector;
	Cv::Features2d::Algorithm->import(qw(Int Bool Double));
	sub nfeatures { &Int }
	sub qualityLevel { &Double }
	sub minDistance { &Double }
	sub useHarrisDetector { &Bool }
	sub k { &Double }
}

=item *
L</DenseFeatureDetector()> - initFeatureScale, featureScaleLevels,
featureScaleMul, initXyStep, varyXyStepWithScale, varyImgBoundWithScale

=cut

{
	package Cv::Features2d::DenseFeatureDetector;
	Cv::Features2d::Algorithm->import(qw(Int Bool Double));
	sub initFeatureScale { &Double }
	sub featureScaleLevels { &Int }
	sub featureScaleMul { &Double }
	sub initXyStep { &Int }
	sub initImgBound { &Int }
	sub varyXyStepWithScale { &Bool }
	sub varyImgBoundWithScale { &Bool }
}


# TODO - test SimpleBlobDetector

{
	package Cv::Features2d::SimpleBlobDetector;
	Cv::Features2d::Algorithm->import(qw(Int Bool Double));
	sub thresholdStep { &Double }
	sub minThreshold { &Double }
	sub maxThreshold { &Double }
	sub minRepeatability { &Int }
	sub minDistBetweenBlobs { &Double }
	sub filterByColor { &Bool }
	sub blobColor { &Int }
	sub filterByArea { &Bool }
	sub maxArea { &Double }
	sub filterByCircularity { &Bool }
	sub maxCircularity { &Double }
	sub filterByInertia { &Bool }
	sub maxInertiaRatio { &Double }
	sub filterByConvexity { &Bool }
	sub maxConvexity { &Double }
}

=item *
L</GridAdaptedFeatureDetector()> - detector, maxTotalKeypoints,
gridRows, gridCols

=cut

{
	package Cv::Features2d::GridAdaptedFeatureDetector;
	Cv::Features2d::Algorithm->import(qw(Int Algorithm));
	sub detector { &Algorithm }
	sub maxTotalKeypoints { &Int }
	sub gridRows { &Int }
	sub gridCols { &Int }
}

=item *
L</PyramidAdaptedFeatureDetector()> - not supported

=back


=head2 AdjusterAdapter

=over

=cut

{
	package Cv::Features2d::AdjusterAdapter;
	our @ISA = qw(Cv::Features2d::FeatureDetector);
}

=item
L<FastAdjuster()|http://docs.opencv.org/search.html?q=FastAdjuster>

=cut

{
	package Cv::Features2d::FastAdjuster;
	our @ISA = qw(Cv::Features2d::AdjusterAdapter);
	our ($THRESH, $INIT_THRESH, $MIN_THRESH, $MAX_THRESH);
	sub tooFew { $THRESH--; }
	sub tooMany { $THRESH++; }
	sub good { $THRESH > $MIN_THRESH && $THRESH < $MAX_THRESH; }
}

=item
L<StarAdjuster()|http://docs.opencv.org/search.html?q=StarAdjuster>

=cut

{
	package Cv::Features2d::StarAdjuster;
	our @ISA = qw(Cv::Features2d::AdjusterAdapter);
	our ($THRESH, $INIT_THRESH, $MIN_THRESH, $MAX_THRESH);
	sub tooFew { $THRESH *= 0.9; $THRESH = 1.1 if $THRESH < 1.1; }
	sub tooMany { $THRESH *= 1.1; }
	sub good { $THRESH > $MIN_THRESH && $THRESH < $MAX_THRESH; }
}

=item
L<SurfAdjuster()|http://docs.opencv.org/search.html?q=SurfAdjuster>

=cut

{
	package Cv::Features2d::SurfAdjuster;
	our @ISA = qw(Cv::Features2d::AdjusterAdapter);
	our ($THRESH, $INIT_THRESH, $MIN_THRESH, $MAX_THRESH);
	sub tooFew { $THRESH *= 0.9; $THRESH = 1.1 if $THRESH < 1.1; }
	sub tooMany { $THRESH *= 1.1; }
	sub good { $THRESH > $MIN_THRESH && $THRESH < $MAX_THRESH; }
}

=back

Use DynamicAdaptedFeatureDetector() with the adjusters.

  my $detector = DynamicAdaptedFeatureDetector(FastAdjuster());

If you adjust the detector parameters, you can define your adjuster as
follows:

  { package Your::FastAdjuster;
    our @ISA = qw(Cv::Features2d::FastAdjuster);
    our ($THRESH, $INIT_THRESH, $MIN_THRESH, $MAX_THRESH);
    sub tooFew { $THRESH--; }
    sub tooMany { $THRESH++; }
    sub good { $THRESH > $MIN_THRESH && $THRESH < $MAX_THRESH; }
  }
  my $detector = DynamicAdaptedFeatureDetector(Your::FastAdjuster->new());


=head2 DescriptorExtractor

=over

=item
L<FREAK()|http://docs.opencv.org/search.html?q=FREAK>

=cut

{
	package Cv::Features2d::FREAK;
	our @ISA = qw(Cv::Features2d::DescriptorExtractor);
	$Cv::Features2d::CLASS{ 'Feature2D.FREAK' } = __PACKAGE__;
	sub new {
		my ($class, $orientationNormalized,
			$scaleNormalized, $patternScale, $nbOctave) = @_;
		if (ref $class) {
			$orientationNormalized = $class->orientationNormalized
				unless defined $orientationNormalized;
			$scaleNormalized = $class->scaleNormalized
				unless defined $scaleNormalized;
			$patternScale = $class->patternScale
				unless defined $patternScale;
			$nbOctave = $class->nbOctave
				unless defined $nbOctave;
		}
		my $self = bless $class->create("FREAK");
		$self->orientationNormalized($orientationNormalized || 1);
		$self->scaleNormalized($scaleNormalized || 1);
		$self->patternScale($patternScale || 22);
		$self->nbOctave($nbOctave || 4);
		$self;
	}
}

=item
L<BriefDescriptorExtractor()|http://docs.opencv.org/search.html?q=BriefDescriptorExtractor>

=cut

{
	package Cv::Features2d::BriefDescriptorExtractor;
	our @ISA = qw(Cv::Features2d::DescriptorExtractor);
	Cv::Features2d::Algorithm->import(qw(Int));
	$Cv::Features2d::CLASS{ 'Feature2D.BRIEF' } = __PACKAGE__;
	sub new {
		my ($class, $bytes) = @_;
		if (ref $class) {
			$bytes = $class->bytes
				unless defined $bytes;
		}
		my $self = bless $class->create("BRIEF");
		$self->bytes($bytes || 32);
		$self;
	}
}

=item
L<OpponentColorDescriptorExtractor()|http://docs.opencv.org/search.html?q=OpponentColorDescriptorExtractor>

=cut

{
	package Cv::Features2d::OpponentColorDescriptorExtractor;
	our @ISA = qw(Cv::Features2d::DescriptorExtractor);
}

sub OpponentColorDescriptorExtractor {
	my $detector = shift;
	return undef unless ref $detector &&
		$detector->name =~ /Feature2D\.(SIFT|SURF|ORB|BRISK|BRIEF)/;
	my $ptr = unbless $detector->new();
	Cv::Features2d::OpponentColorDescriptorExtractor->new($ptr, @_);
}

=back

  my $extractor = FREAK();
  my $extractor = BriefDescriptorExtractor();
  my $extractor = OpponentColorDescriptorExtractor(SIFT()); # SIFT, SURF, ORB, BRISK, BRIEF

=over

=item
L<compute()|http://docs.opencv.org/search.html?q=DescriptorExtractor::compute>

=back

  my $desc = $extractor->compute($img, $kp);

properties are:

=over

=item *
L</FREAK()> - orientationNormalized, scaleNormalized, patternScale, nbOctave

=cut

{
	package Cv::Features2d::FREAK;
	Cv::Features2d::Algorithm->import(qw(Int Double Bool));
	sub orientationNormalized { &Bool }
	sub scaleNormalized { &Bool }
	sub patternScale { &Double }
	sub nbOctave { &Int }
}

=item *
L</BriefDescriptorExtractor()> - bytes

=cut

{
	package Cv::Features2d::BriefDescriptorExtractor;
	Cv::Features2d::Algorithm->import(qw(Int));
	sub bytes { &Int }
}

=item *
L</OpponentColorDescriptorExtractor()> - not supported

=back

=head2 DescriptorMatcher

=over

=item
L<BFMatcher()|http://docs.opencv.org/search.html?q=BFMatcher>

=cut

{
	package Cv::Features2d::DescriptorMatcher::BFMatcher;
	our @ISA = qw(Cv::Features2d::DescriptorMatcher);
	$Cv::Features2d::CLASS{ 'DescriptorMatcher.BFMatcher' } = __PACKAGE__;
}

=item
L<FlannBasedMatcher()|http://docs.opencv.org/search.html?q=FlannBasedMatcher>

=back

  my $matcher = BFMatcher();
  my $matcher = FlannBasedMatcher($indexParams, $searchParams);

The parameters of FlannBasedMatcher() are hashrefs as follows:

  my $matcher = FlannBasedMatcher(
    my $indexParams = {
      algorithm => 6,
      table_number => 6,
      key_size => 12,
      multi_probe_level => 1,
    });

To define SearchParams (one of IndexParams).

  my $searchParams = {
    'checks:i' => 32,       # int
    'eps:f' => 0,           # float
    'sorted:b' => 1,        # bool
  };

IndexParams stores the key-value pairs. The type of the value stored
in the IndexParams is more detailed than Perl SV.  There are double,
float, int, bool, and string.  To clarify the type of them, you can
put a letter with a colon after the name.  The letter is as follows:

  letter  | type of IndexParams
 ------------------------------------
     d    |    double
     f    |    float
     i    |    int
     b    |    bool
     a    |    string

If there is no type letter, the type of IndexParams is mapped from
sv-type.

  sv-type | type of IndexParams
 ------------------------------------
    NV    |    double
    IV    |    int
    PV    |    string

Please see the samples in t/indexparam.t and sample/find_obj.pl.


=over

=item
L<match()|http://docs.opencv.org/search.html?q=DescriptorMatcher::match>

=item
L<knnMatch()|http://docs.opencv.org/search.html?q=DescriptorMatcher::knnMatch>

=item
L<radiusMatch()|http://docs.opencv.org/search.html?q=DescriptorMatcher::radiusMatch>

=back

  my $matches = $matcher->match($desc, $desc2, $mask);
  my $matches = $matcher->knnMatch($desc, $desc2, $k, $mask, $compact);
  my $matches = $matcher->radiusMatch($desc, $desc2, $maxDist, $mask, $compact);

properties are:

=over

=item *
L</BFMatcher()> -  normType, crossCheck

=cut

{
	package Cv::Features2d::DescriptorMatcher::BFMatcher;
	our @ISA = qw(Cv::Features2d::DescriptorMatcher);
	Cv::Features2d::Algorithm->import(qw(Int Bool));
	sub normType { &Int }
	sub crossCheck { &Bool }
}

=item *
L</FlannBasedMatcher()> - not supported

=cut

{
	package Cv::Features2d::DescriptorMatcher::FlannBasedMatcher;
	our @ISA = qw(Cv::Features2d::DescriptorMatcher);
	$Cv::Features2d::CLASS{ 'DescriptorMatcher.FlannBasedMatcher' } = __PACKAGE__;
	package Cv::IndexParams;
	our $VERBOSE = 0;
}

=back

=head2 Drawing Function

=over

=item
L<drawKeypoints()|http://docs.opencv.org/search.html?q=drawKeypoints>

=item
L<drawMatches()|http://docs.opencv.org/search.html?q=drawMatches>

=back

  drawKeypoints($image, $keypoints, $color, $flags);
  my $image = drawMatches($img1, $keypoints1, $img2, $keypoints2);

=cut

*Cv::Arr::drawKeypoints = \&drawKeypoints;
*Cv::Arr::drawMatches = \&drawMatches;

while (my ($name, $package) = each %CLASS) {
	eval "package ${package}::Ghost; our \@ISA = qw($package); sub DESTROY {}";
}

1;
__END__

=head2 EXPORT

None by default.


=head1 SEE ALSO

L<http://github.com/yuta-masuda/Cv>


=head1 AUTHOR

MASUDA Yuta E<lt>yuta.cpan@gmail.comE<gt>


=head1 LICENCE

Copyright (c) 2013 by MASUDA Yuta.

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl itself.

=cut
