# -*- mode: perl; coding: utf-8; tab-width: 4 -*-

use strict;
use warnings;
use Test::More qw(no_plan);
# use Test::More;
use Test::Exception;
BEGIN { use_ok('Cv', -nonfree) }
BEGIN { use_ok('Cv::Features2d', qw(:all)) }

if (1) {
	my $p = SIFT();
	lives_ok { $p->name };
	is($Cv::Features2d::CLASS{$p->name}, ref $p);
	my $q = $p->new();
	is($q->nFeatures, $p->nFeatures);
	is($q->nOctaveLayers, $p->nOctaveLayers);
	is($q->contrastThreshold, $p->contrastThreshold);
	is($q->edgeThreshold, $p->edgeThreshold);
	is($q->sigma, $p->sigma);
}

if (2) {
	my $p = SURF(100);
	lives_ok { $p->name };
	is($Cv::Features2d::CLASS{$p->name}, ref $p);
	my $q = $p->new();
	is($q->hessianThreshold, $p->hessianThreshold);
	is($q->nOctaves, $p->nOctaves);
	is($q->nOctaveLayers, $p->nOctaveLayers);
	is($q->extended, $p->extended);
	is($q->upright, $p->upright);
}

if (3) {
	my $p = ORB();
	lives_ok { $p->name };
	is($Cv::Features2d::CLASS{$p->name}, ref $p);
	my $q = $p->new();
	is($q->nFeatures, $p->nFeatures);
	is($q->scaleFactor, $p->scaleFactor);
	is($q->nLevels, $p->nLevels);
	is($q->firstLevel, $p->firstLevel);
	is($q->edgeThreshold, $p->edgeThreshold);
	is($q->patchSize, $p->patchSize);
	is($q->WTA_K, $p->WTA_K);
	is($q->scoreType, $p->scoreType);
}

if (4) {
	my $p = BRISK();
	lives_ok { $p->name };
	is($Cv::Features2d::CLASS{$p->name}, ref $p);
	my $q = $p->new();
	is($q->thres, $p->thres);
	is($q->octaves, $p->octaves);
}

if (5) {
	my $p = FastFeatureDetector(10, 0);
	lives_ok { $p->name };
	is($Cv::Features2d::CLASS{$p->name}, ref $p);
	my $q = $p->new();
	is($q->threshold, $p->threshold);
	is($q->nonmaxSuppression, $p->nonmaxSuppression);
	# is($q->type, $p->type);
}

if (6) {
	my $p = StarFeatureDetector();
	lives_ok { $p->name };
	is($Cv::Features2d::CLASS{$p->name}, ref $p);
	my $q = $p->new();
	is($q->maxSize, $p->maxSize);
	is($q->responseThreshold, $p->responseThreshold);
	is($q->lineThresholdProjected, $p->lineThresholdProjected);
	is($q->lineThresholdBinarized, $p->lineThresholdBinarized);
	is($q->suppressNonmaxSize, $p->suppressNonmaxSize);
}

if (7) {
	my $p = GoodFeaturesToTrackDetector();
	lives_ok { $p->name };
	is($Cv::Features2d::CLASS{$p->name}, ref $p);
	my $q = $p->new();
	is($q->nfeatures, $p->nfeatures);
	is($q->qualityLevel, $p->qualityLevel);
	is($q->minDistance, $p->minDistance);
	is($q->useHarrisDetector, $p->useHarrisDetector);
	is($q->k, $p->k);
}

if (8) {
	my $p = MserFeatureDetector(5, 60, 14400, 0.25, 0.2, 200, 1.01, 0.003, 5);
	lives_ok { $p->name };
	is($Cv::Features2d::CLASS{$p->name}, ref $p);
	my $q = $p->new();
	is($q->delta, $p->delta);
	is($q->minArea, $p->minArea);
	is($q->maxArea, $p->maxArea);
	is($q->maxVariation, $p->maxVariation);
	is($q->minDiversity, $p->minDiversity);
	is($q->maxEvolution, $p->maxEvolution);
	is($q->areaThreshold, $p->areaThreshold);
	is($q->minMargin, $p->minMargin);
	is($q->edgeBlurSize, $p->edgeBlurSize);
}

if (9) {
	my $p = DenseFeatureDetector();
	lives_ok { $p->name };
	is($Cv::Features2d::CLASS{$p->name}, ref $p);
	my $q = $p->new();
	is($q->initFeatureScale, $p->initFeatureScale);
	is($q->featureScaleLevels, $p->featureScaleLevels);
	is($q->featureScaleMul, $p->featureScaleMul);
	is($q->initXyStep, $p->initXyStep);
	is($q->initImgBound, $p->initImgBound);
	is($q->varyXyStepWithScale, $p->varyXyStepWithScale);
	is($q->varyImgBoundWithScale, $p->varyImgBoundWithScale);
}

if (10) {
	my $p = GridAdaptedFeatureDetector(SURF(500), 100);
	lives_ok { $p->name };
	is($Cv::Features2d::CLASS{$p->name}, ref $p);
	my $detector = $p->detector;
	my $q = $p->new();
	is($q->maxTotalKeypoints, $p->maxTotalKeypoints);
	is($q->gridRows, $p->gridRows);
	is($q->gridCols, $p->gridCols);
}

if (11) {
	my $p = SimpleBlobDetector();
	lives_ok { $p->name };
	is($Cv::Features2d::CLASS{$p->name}, ref $p);
	my $q = $p->new();
	is($q->thresholdStep, $p->thresholdStep);
	is($q->minThreshold, $p->minThreshold);
	is($q->maxThreshold, $p->maxThreshold);
	is($q->minRepeatability, $p->minRepeatability);
	is($q->minDistBetweenBlobs, $p->minDistBetweenBlobs);
	is($q->filterByColor, $p->filterByColor);
	is($q->blobColor, $p->blobColor);
	is($q->filterByArea, $p->filterByArea);
	is($q->maxArea, $p->maxArea);
	is($q->filterByCircularity, $p->filterByCircularity);
	is($q->maxCircularity, $p->maxCircularity);
	is($q->filterByInertia, $p->filterByInertia);
	is($q->maxInertiaRatio, $p->maxInertiaRatio);
	is($q->filterByConvexity, $p->filterByConvexity);
	is($q->maxConvexity, $p->maxConvexity);
}

if (12) {
	my $p = BriefDescriptorExtractor();
	lives_ok { $p->name };
	is($Cv::Features2d::CLASS{$p->name}, ref $p);
	my $q = $p->new();
	is($q->bytes, $p->bytes);
}

if (13) {
	my $p = FREAK();
	lives_ok { $p->name };
	is($Cv::Features2d::CLASS{$p->name}, ref $p);
	my $q = $p->new();
	is($q->orientationNormalized, $p->orientationNormalized);
	is($q->scaleNormalized, $p->scaleNormalized);
	is($q->patternScale, $p->patternScale);
	is($q->nbOctave, $p->nbOctave);
}

if (14) {
	my $p = BFMatcher();
	lives_ok { $p->name };
	is($Cv::Features2d::CLASS{$p->name}, ref $p);
	lives_ok { $p->normType };
	lives_ok { $p->crossCheck };
}

if (99) {
	for my $class (
		qw(Cv::Features2d::FeatureDetector),
		qw(Cv::Features2d::Feature2D),
		qw(Cv::Features2d::Feature2D::SURF),
		) {
		my $surf = $class->create("SURF");
		lives_ok { $surf->get_double("hessianThreshold") };
	}
}
