# -*- mode: perl; coding: utf-8; tab-width: 4; -*-

=encoding utf8

=head1 NAME

Cv::Features2d - Cv extension for OpenCV Features Detector

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

use 5.010;
use strict;
use warnings;
use Carp;
use Data::Structure::Util qw(unbless);
use Cv ();

our $VERSION = '0.08';

require XSLoader;
XSLoader::load('Cv::Features2d', $VERSION);

require Exporter;

our @ISA = qw(Exporter);

our @EXPORT_OK = (qw(drawKeypoints drawMatches),
				  qw(PyramidAdaptedFeatureDetector),
	);
our %EXPORT_TAGS = ( 'all' => \@EXPORT_OK );
our @EXPORT = ( );

our %CLASS;

for (classes(__PACKAGE__)) {
	if ($_->can('new')) {
		my $name = (split('::', $_))[-1];
		unless (__PACKAGE__->can($name)) {
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
		$self->set_algorithm($name, $_[0]) if defined $_[0];
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
}


=head2 Feature2D

There are constructors for extracting keypoints and computing
descriptors.

=over

=item
L<ORB()|http://docs.opencv.org/search.html?q=ORB>

=cut

{
	package Cv::Features2d::Feature2D::ORB;
	use constant { kBytes => 32, HARRIS_SCORE => 0, FAST_SCORE => 1 };
	our @ISA = qw(Cv::Features2d::Feature2D);
	$Cv::Features2d::CLASS{ 'Feature2D.ORB' } = __PACKAGE__;
	sub new {
		my ($class, $nFeatures, $scaleFactor, $nLevels,
			$edgeThreshold, $firstLevel, $WTA_K, $scoreType,
			$patchSize) = @_;
		if (ref $class) {
			$nFeatures //= $class->nFeatures;
			$scaleFactor //= $class->scaleFactor;
			$nLevels //= $class->nLevels;
			$edgeThreshold //= $class->edgeThreshold;
			$firstLevel //= $class->firstLevel;
			$WTA_K //= $class->WTA_K;
			$scoreType //= $class->scoreType;
			$patchSize //= $class->patchSize;
		}
		my $self = bless $class->create("ORB");
		$self->nFeatures($nFeatures // 500);
		$self->scaleFactor($scaleFactor // 1.2);
		$self->nLevels($nLevels // 8);
		$self->edgeThreshold($edgeThreshold // 31);
		$self->firstLevel($firstLevel // 0);
		$self->WTA_K($WTA_K // 2);
		$self->scoreType($scoreType // HARRIS_SCORE);
		$self->patchSize($patchSize // 31);
		$self;
	}
}


=item
L<BRISK()|http://docs.opencv.org/search.html?q=BRISK>

=cut

{
	package Cv::Features2d::Feature2D::BRISK;
	our @ISA = qw(Cv::Features2d::Feature2D);
	$Cv::Features2d::CLASS{ 'Feature2D.BRISK' } = __PACKAGE__;
	sub new {
		my ($class, $thres, $octaves) = @_;
		if (ref $class) {
			$thres //= $class->thres;
			$octaves //= $class->octaves;
		}
		my $self = bless $class->create("BRISK");
		$self->thres($thres // 30);
		$self->octaves($octaves // 3);
		$self;
	}
}


=item
L<SIFT()|http://docs.opencv.org/search.html?q=SIFT>

=cut

{
	package Cv::Features2d::Feature2D::SIFT;
	our @ISA = qw(Cv::Features2d::Feature2D);
	sub new {
		my ($class, $nFeatures, $nOctaveLayers, $contrastThreshold,
			$edgeThreshold, $sigma) = @_;
		if (ref $class) {
			$nFeatures //= $class->nFeatures;
			$nOctaveLayers //= $class->nOctaveLayers;
			$contrastThreshold //= $class->contrastThreshold;
			$edgeThreshold //= $class->edgeThreshold;
			$sigma //= $class->sigma;
		}
		my $self = bless $class->create("SIFT");
		$self->nFeatures($nFeatures // 0);
		$self->nOctaveLayers($nOctaveLayers // 3);
		$self->contrastThreshold($contrastThreshold // 0.04);
		$self->edgeThreshold($edgeThreshold // 10);
		$self->sigma($sigma // 1.6);
		$self;
	}
}


=item
L<SURF()|http://docs.opencv.org/search.html?q=SURF>

=cut

{
	package Cv::Features2d::Feature2D::SURF;
	our @ISA = qw(Cv::Features2d::Feature2D);
	$Cv::Features2d::CLASS{ 'Feature2D.SURF' } = __PACKAGE__;
	sub new {
		my ($class, $hessianThreshold, $nOctaves, $nOctaveLayers,
			$extended, $upright) = @_;
		if (ref $class) {
			$hessianThreshold //= $class->hessianThreshold;
			$nOctaves //= $class->nOctaves;
			$nOctaveLayers //= $class->nOctaveLayers;
			$extended //= $class->extended;
			$upright //= $class->upright;
		}
		my $self = bless $class->create("SURF");
		$self->hessianThreshold($hessianThreshold);
		$self->nOctaves($nOctaves // 4);
		$self->nOctaveLayers($nOctaveLayers // 2);
		$self->extended($extended // 1);
		$self->upright($upright // 0);
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

ORB() - nFeatures, scaleFactor, nLevels, edgeThreshold,
firstLevel, WTA_K, scoreType, patchSize

=cut

{
	package Cv::Features2d::Feature2D::ORB;
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

BRISK() - thres, octaves

=cut

{
	package Cv::Features2d::Feature2D::BRISK;
	Cv::Features2d::Algorithm->import(qw(Int Double));
	sub thres { &Int }
	sub octaves { &Int }
}

=item *

SIFT() - nFeatures, nOctaveLayers, contrastThreshold,
edgeThreshold, sigma

=cut

{
	package Cv::Features2d::Feature2D::SIFT;
	Cv::Features2d::Algorithm->import(qw(Int Double));
	sub nFeatures { &Int }
	sub nOctaveLayers { &Int }
	sub contrastThreshold { &Double }
	sub edgeThreshold { &Double }
	sub sigma { &Double }
}

=item *

SURF() - hessianThreshold, nOctaves, nOctaveLayers,
extended, upright

=cut

{
	package Cv::Features2d::Feature2D::SURF;
	Cv::Features2d::Algorithm->import(qw(Int Double Bool));
	sub hessianThreshold { &Double }
	sub nOctaves { &Int }
	sub nOctaveLayers { &Int }
	sub extended { &Bool }
	sub upright { &Bool }
}


=head2 FeatureDetector

=over

=item
L<FastFeatureDetector()|http://docs.opencv.org/search.html?q=FastFeatureDetector>

=cut

{
	package Cv::Features2d::FeatureDetector::FastFeatureDetector;
	our @ISA = qw(Cv::Features2d::FeatureDetector);
	$Cv::Features2d::CLASS{ 'Feature2D.FAST' } = __PACKAGE__;
	sub new {
		my ($class, $threshold, $nonmaxSuppression, $type) = @_;
		if (ref $class) {
			$threshold //= $class->threshold;
			$nonmaxSuppression //= $class->nonmaxSuppression;
		}
		my $self = bless $class->create("FAST");
		$self->threshold($threshold // 1);
		$self->nonmaxSuppression($nonmaxSuppression // 1);
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
	package Cv::Features2d::FeatureDetector::StarFeatureDetector;
	our @ISA = qw(Cv::Features2d::FeatureDetector);
	$Cv::Features2d::CLASS{ 'Feature2D.STAR' } = __PACKAGE__;
	sub new {
		my ($class, $maxSize, $responseThreshold,
			$lineThresholdProjected, $lineThresholdBinarized,
			$suppressNonmaxSize) = @_;
		if (ref $class) {
			$maxSize //= $class->maxSize;
			$responseThreshold //= $class->responseThreshold;
			$lineThresholdProjected //= $class->lineThresholdProjected;
			$lineThresholdBinarized //= $class->lineThresholdBinarized;
			$suppressNonmaxSize //= $class->suppressNonmaxSize;
		}
		my $self = bless $class->create("STAR");
		$self->maxSize($maxSize // 16);
		$self->responseThreshold($responseThreshold // 30);
		$self->lineThresholdProjected($lineThresholdProjected // 10);
		$self->lineThresholdBinarized($lineThresholdBinarized // 8);
		$self->suppressNonmaxSize($suppressNonmaxSize // 5);
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
	package Cv::Features2d::FeatureDetector::MserFeatureDetector;
	our @ISA = qw(Cv::Features2d::FeatureDetector);
	$Cv::Features2d::CLASS{ 'Feature2D.MSER' } = __PACKAGE__;
	sub new {
		my ($class, $delta, $minArea, $maxArea, $maxVariation,
			$minDiversity, $maxEvolution, $areaThreshold, $minMargin,
			$edgeBlurSize) = @_;
		if (ref $class) {
			$delta //= $class->delta;
			$minArea //= $class->minArea;
			$maxArea //= $class->maxArea;
			$maxVariation //= $class->maxVariation;
			$minDiversity //= $class->minDiversity;
			$maxEvolution //= $class->maxEvolution;
			$areaThreshold //= $class->areaThreshold;
			$minMargin //= $class->minMargin;
			$edgeBlurSize //= $class->edgeBlurSize;
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
	package Cv::Features2d::FeatureDetector::GoodFeaturesToTrackDetector;
	our @ISA = qw(Cv::Features2d::FeatureDetector);
	our $detectorType = "GFTT";	# GFTT or HARRIS
	$Cv::Features2d::CLASS{ "Feature2D.$detectorType" } = __PACKAGE__;
	sub new {
		my ($class, $nfeatures, $qualityLevel, $minDistance,
			$useHarrisDetector, $k) = @_;
		if (ref $class) {
			$nfeatures //= $class->nfeatures;
			$qualityLevel //= $class->qualityLevel;
			$minDistance //= $class->minDistance;
			$useHarrisDetector //= $class->useHarrisDetector;
			$k //= $class->k;
		}
		my $self = bless $class->create($detectorType);
		$self->nfeatures($nfeatures // 1000);
		$self->qualityLevel($qualityLevel // 0.01);
		$self->minDistance($minDistance // 1.0);
		$self->useHarrisDetector($useHarrisDetector // 0);
		$self->k($k // 0.04);
		$self;
	}
}

=item
L<DenseFeatureDetector()|http://docs.opencv.org/search.html?q=DenseFeatureDetector>

=cut

{
	package Cv::Features2d::FeatureDetector::DenseFeatureDetector;
	our @ISA = qw(Cv::Features2d::FeatureDetector);
	$Cv::Features2d::CLASS{ 'Feature2D.Dense' } = __PACKAGE__;
	sub new {
		my ($class, $initFeatureScale, $featureScaleLevels,
			$featureScaleMul, $initXyStep, $initImgBound,
			$varyXyStepWithScale, $varyImgBoundWithScale) = @_;
		if (ref $class) {
			$initFeatureScale //= $class->initFeatureScale;
			$featureScaleLevels //= $class->featureScaleLevels;
			$featureScaleMul //= $class->featureScaleMul;
			$initXyStep //= $class->initXyStep;
			$initImgBound //= $class->initImgBound;
			$varyXyStepWithScale //= $class->varyXyStepWithScale;
			$varyImgBoundWithScale //= $class->varyImgBoundWithScale;
		}
		my $self = bless $class->create("Dense");
		$self->initFeatureScale($initFeatureScale // 1);
		$self->featureScaleLevels($featureScaleLevels // 1);
		$self->featureScaleMul($featureScaleMul // 0.1);
		$self->initXyStep($initXyStep // 6);
		$self->initImgBound($initImgBound // 0);
		$self->varyXyStepWithScale($varyXyStepWithScale // 1);
		$self->varyImgBoundWithScale($varyImgBoundWithScale // 0);
		$self;
	}
}

=item
L<SimpleBlobDetector|http://docs.opencv.org/search.html?q=SimpleBlobDetector>
()

=cut

{
	package Cv::Features2d::FeatureDetector::SimpleBlobDetector;
	our @ISA = qw(Cv::Features2d::FeatureDetector);
	$Cv::Features2d::CLASS{ 'Feature2D.SimpleBlob' } = __PACKAGE__;
	sub new {
		my ($class, $thresholdStep, $minThreshold, $maxThreshold,
			$minRepeatability, $minDistBetweenBlobs,
			$filterByColor, $blobColor,
			$filterByArea, $minArea, $maxArea,
			$filterByCircularity, $minCircularity, $maxCircularity,
			$filterByInertia, $minInertiaRatio, $maxInertiaRatio,
			$filterByConvexity, $minConvexity, $maxConvexity) = @_;
		if (ref $class) {
			$thresholdStep //= $class->thresholdStep;
			$minThreshold //= $class->minThreshold;
			$maxThreshold //= $class->maxThreshold;
			$minRepeatability //= $class->minRepeatability;
			$minDistBetweenBlobs //= $class->minDistBetweenBlobs;
			$filterByColor //= $class->filterByColor;
			$blobColor //= $class->blobColor;
			$filterByArea //= $class->filterByArea;
			$minArea //= $class->minArea;
			$maxArea //= $class->maxArea;
			$filterByCircularity //= $class->filterByCircularity;
			$minCircularity //= $class->minCircularity;
			$maxCircularity //= $class->maxCircularity;
			$filterByInertia //= $class->filterByInertia;
			$minInertiaRatio //= $class->minInertiaRatio;
			$maxInertiaRatio //= $class->maxInertiaRatio;
			$filterByConvexity //= $class->filterByConvexity;
			$minConvexity //= $class->minConvexity;
			$maxConvexity //= $class->maxConvexity;
		}
		my $self = bless $class->create("SimpleBlob");
		$self->thresholdStep($thresholdStep);
		$self->minThreshold($minThreshold);
		$self->maxThreshold($maxThreshold);
		$self->minRepeatability($minRepeatability);
		$self->minDistBetweenBlobs($minDistBetweenBlobs);
		$self->filterByColor($filterByColor);
		$self->blobColor($blobColor);
		$self->filterByArea($filterByArea);
		$self->maxArea($maxArea);
		$self->filterByCircularity($filterByCircularity);
		$self->maxCircularity($maxCircularity);
		$self->filterByInertia($filterByInertia);
		$self->maxInertiaRatio($maxInertiaRatio);
		$self->filterByConvexity($filterByConvexity);
		$self->maxConvexity($maxConvexity);
		$self;
	}
}

=item
L<GridAdaptedFeatureDetector()|http://docs.opencv.org/search.html?q=GridAdaptedFeatureDetector>

=cut

{
	package Cv::Features2d::FeatureDetector::GridAdaptedFeatureDetector;
	use Data::Structure::Util qw(unbless);
	use Scalar::Util qw(blessed);
	our @ISA = qw(Cv::Features2d::FeatureDetector);
	$Cv::Features2d::CLASS{ 'Feature2D.Grid' } = __PACKAGE__;
	sub new {
		my ($class, $detector, $maxTotalKeypoints, $gridRows,
			$gridCols) = @_;
		my $release_detector = 0;
		if (ref $class) {
			$detector //= $class->detector;
			$maxTotalKeypoints //= $class->maxTotalKeypoints;
			$gridRows //= $class->gridRows;
			$gridCols //= $class->gridCols;
		}
		return undef unless ref $detector;
		my $detectorType = (split(/\./, $detector->name))[-1];
		# return undef unless $detectorType =~ /^(SURF|FAST|STAR)$/;
		my $self = bless $class->create("Grid$detectorType");
		if ($self) {
			my $self_detector = $self->detector();
			bless $self_detector, ref $detector;
			if ($self_detector->can('copy')) {
				$detector->copy($self_detector);
			}
			unbless $self_detector;
			$self->maxTotalKeypoints($maxTotalKeypoints);
			$self->gridRows($gridRows // 4);
			$self->gridCols($gridCols // 4);
		}
		$self;
	}
}


=item
L<PyramidAdaptedFeatureDetector()|http://docs.opencv.org/search.html?q=PyramidAdaptedFeatureDetector>

=cut

{
	package Cv::Features2d::FeatureDetector::PyramidAdaptedFeatureDetector;
	our @ISA = qw(Cv::Features2d::FeatureDetector);
}

sub PyramidAdaptedFeatureDetector {
	my $detector = shift;
	return undef unless ref $detector &&
		$detector->name =~ /Feature2D\.(SURF|FAST|STAR|SIFT)/;
	my $ptr = unbless $detector->new();
	Cv::Features2d::FeatureDetector::PyramidAdaptedFeatureDetector
		->new($ptr, @_);
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

FastFeatureDetector() - threshold, nonmaxSuppression

=cut

{
	package Cv::Features2d::FeatureDetector::FastFeatureDetector;
	Cv::Features2d::Algorithm->import(qw(Int Bool));
	sub threshold { &Int }
	sub nonmaxSuppression { &Bool }
}


=item *

StarFeatureDetector() - maxSize, responseThreshold, lineThresholdProjected,
lineThresholdBinarized, suppressNonmaxSize

=cut

{
	package Cv::Features2d::FeatureDetector::StarFeatureDetector;
	Cv::Features2d::Algorithm->import(qw(Int));
	sub maxSize { &Int }
	sub responseThreshold { &Int }
	sub lineThresholdProjected { &Int }
	sub lineThresholdBinarized { &Int }
	sub suppressNonmaxSize { &Int }
}


=item *

MserFeatureDetector() - delta, minArea, maxArea, maxVariation,
minDiversity, maxEvolution, minMargin, edgeBlurSize

=cut

{
	package Cv::Features2d::FeatureDetector::MserFeatureDetector;
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

GoodFeaturesToTrackDetector() - nfeatures, qualityLevel, minDistance,
useHarrisDetector, k

=cut

{
	package Cv::Features2d::FeatureDetector::GoodFeaturesToTrackDetector;
	Cv::Features2d::Algorithm->import(qw(Int Bool Double));
	sub nfeatures { &Int }
	sub qualityLevel { &Double }
	sub minDistance { &Double }
	sub useHarrisDetector { &Bool }
	sub k { &Double }
}

=item *

DenseFeatureDetector() - initFeatureScale, featureScaleLevels,
featureScaleMul, initXyStep, varyXyStepWithScale, varyImgBoundWithScale

=cut

{
	package Cv::Features2d::FeatureDetector::DenseFeatureDetector;
	Cv::Features2d::Algorithm->import(qw(Int Bool Double));
	sub initFeatureScale { &Double }
	sub featureScaleLevels { &Int }
	sub featureScaleMul { &Double }
	sub initXyStep { &Int }
	sub initImgBound { &Int }
	sub varyXyStepWithScale { &Bool }
	sub varyImgBoundWithScale { &Bool }
}


=item *

=cut

{
	package Cv::Features2d::FeatureDetector::SimpleBlobDetector;
	Cv::Features2d::Algorithm->import(qw(Int Bool Double));
	sub thresholdStep { &Double }
	sub minThreshold { &Double }
	sub maxThreshold { &Double }
	sub minRepeatability { &Int }
	sub minDistBetweenBlobs { &Double }
	sub filterByColor { &Bool }
	sub blobColor { &Int }
	sub filterByArea { &Bool }
	sub minArea { &Double }
	sub maxArea { &Double }
	sub filterByCircularity { &Bool }
	sub minCircularity { &Double }
	sub maxCircularity { &Double }
	sub filterByInertia { &Bool }
	sub minInertiaRatio { &Double }
	sub maxInertiaRatio { &Double }
	sub filterByConvexity { &Bool }
	sub minConvexity { &Double }
	sub maxConvexity { &Double }
}


=item *

GridAdaptedFeatureDetector() - detector, maxTotalKeypoints,
gridRows, gridCols

=cut

{
	package Cv::Features2d::FeatureDetector::GridAdaptedFeatureDetector;
	Cv::Features2d::Algorithm->import(qw(Int Algorithm));
	sub detector { &Algorithm }
	sub maxTotalKeypoints { &Int }
	sub gridRows { &Int }
	sub gridCols { &Int }
}


=item *

PyramidAdaptedFeatureDetector() - not supported

=back

=head2 DescriptorExtractor

=over

=item
L<FREAK()|http://docs.opencv.org/search.html?q=FREAK>

=cut

{
	package Cv::Features2d::DescriptorExtractor::FREAK;
	our @ISA = qw(Cv::Features2d::DescriptorExtractor);
	$Cv::Features2d::CLASS{ 'Feature2D.FREAK' } = __PACKAGE__;
	sub new {
		my ($class, $orientationNormalized,
			$scaleNormalized, $patternScale, $nbOctave) = @_;
		if (ref $class) {
			$orientationNormalized //= $class->orientationNormalized;
			$scaleNormalized //= $class->scaleNormalized;
			$patternScale //= $class->patternScale;
			$nbOctave //= $class->nOctaves;
		}
		my $self = bless $class->create("FREAK");
		$self->orientationNormalized($orientationNormalized // 1);
		$self->scaleNormalized($scaleNormalized // 1);
		$self->patternScale($patternScale // 22);
		$self->nbOctave($nbOctave // 4);
		$self;
	}
}

=item
L<BriefDescriptorExtractor()|http://docs.opencv.org/search.html?q=BriefDescriptorExtractor>

=cut

{
	package Cv::Features2d::DescriptorExtractor::BriefDescriptorExtractor;
	our @ISA = qw(Cv::Features2d::DescriptorExtractor);
	Cv::Features2d::Algorithm->import(qw(Int));
	$Cv::Features2d::CLASS{ 'Feature2D.BRIEF' } = __PACKAGE__;
	sub new {
		my ($class, $bytes) = @_;
		if (ref $class) {
			$bytes //= $class->bytes;
		}
		my $self = bless $class->create("BRIEF");
		$self->bytes($bytes // 32);
		$self;
	}
}


=item
L<OpponentColorDescriptorExtractor()|http://docs.opencv.org/search.html?q=OpponentColorDescriptorExtractor>

=cut

{
	package Cv::Features2d::DescriptorExtractor::OpponentColorDescriptorExtractor;
	our @ISA = qw(Cv::Features2d::DescriptorExtractor);
	sub new {
		my ($class, $dextractor) = @_;
		my $descriptorExtractorType = ref $dextractor?
			(split(/\./, $dextractor->name))[-1] : $dextractor;
		return undef unless $descriptorExtractorType =~ /^(SIFT|SURF|ORB|BRISK|BRIEF)$/;
		bless $class->create("Opponent$descriptorExtractorType");
	}
}

=back

  my $extractor = FREAK();
  my $extractor = BriefDescriptorExtractor();
  my $extractor = OpponentColorDescriptorExtractor("ORB"); # SIFT, SURF, ORB, BRISK, BRIEF

=over

=item
L<compute()|http://docs.opencv.org/search.html?q=DescriptorExtractor::compute>

=back

  my $desc = $extractor->compute($img, $kp);

properties are:

=over

=item *

FREAK() - orientationNormalized, scaleNormalized, patternScale, nbOctave

=cut

{
	package Cv::Features2d::DescriptorExtractor::FREAK;
	Cv::Features2d::Algorithm->import(qw(Int Double Bool));
	sub orientationNormalized { &Bool }
	sub scaleNormalized { &Bool }
	sub patternScale { &Double }
	sub nbOctave { &Int }
}


=item *

BriefDescriptorExtractor() - bytes

=cut

{
	package Cv::Features2d::DescriptorExtractor::BriefDescriptorExtractor;
	Cv::Features2d::Algorithm->import(qw(Int));
	sub bytes { &Int }
}

=item *

OpponentColorDescriptorExtractor() - not supported

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

BFMatcher() -  normType, crossCheck

=cut

{
	package Cv::Features2d::DescriptorMatcher::BFMatcher;
	our @ISA = qw(Cv::Features2d::DescriptorMatcher);
	Cv::Features2d::Algorithm->import(qw(Int));
	sub normType { &Int }
	sub crossCheck { &Bool }
}

=item *

FlannBasedMatcher() - not supported

=cut

{
	package Cv::Features2d::DescriptorMatcher::FlannBasedMatcher;
	our @ISA = qw(Cv::Features2d::DescriptorMatcher);
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

=back

=head2 EXPORT

None by default.


=head1 SEE ALSO

http://github.com/yuta-masuda/Cv-Features2d


=head1 AUTHOR

MASUDA Yuta E<lt>yuta.cpan@gmail.comE<gt>


=head1 LICENCE

Copyright (c) 2013 by MASUDA Yuta.

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl itself.

=cut
