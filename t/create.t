# -*- mode: perl; coding: utf-8; tab-width: 4 -*-

use strict;
use warnings;
use Test::More qw(no_plan);
# use Test::More;
use Test::Exception;
BEGIN { use_ok('Cv') }
BEGIN { use_ok('Cv::Features2d', qw(:all)) }

if (1) {
	my $p = SIFT();
	my $q = $p->new();
	is($q->nFeatures, $p->nFeatures);
	is($q->nOctaveLayers, $p->nOctaveLayers);
	is($q->contrastThreshold, $p->contrastThreshold);
	is($q->edgeThreshold, $p->edgeThreshold);
	is($q->sigma, $p->sigma);
}

if (1) {
	my $p = SURF(100);
	my $q = $p->new();
	is($q->hessianThreshold, $p->hessianThreshold);
	is($q->nOctaves, $p->nOctaves);
	is($q->nOctaveLayers, $p->nOctaveLayers);
	is($q->extended, $p->extended);
	is($q->upright, $p->upright);
}

if (1) {
	my $p = ORB();
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

if (1) {
	my $p = BRISK();
	my $q = $p->new();
	is($q->thres, $p->thres);
	is($q->octaves, $p->octaves);
}

if (1) {
	my $p = FastFeatureDetector(10, 0);
	my $q = $p->new();
	is($q->threshold, $p->threshold);
	is($q->nonmaxSuppression, $p->nonmaxSuppression);
	# is($q->type, $p->type);
}

if (1) {
	my $p = StarFeatureDetector();
	my $q = $p->new();
	is($q->maxSize, $p->maxSize);
	is($q->responseThreshold, $p->responseThreshold);
	is($q->lineThresholdProjected, $p->lineThresholdProjected);
	is($q->lineThresholdBinarized, $p->lineThresholdBinarized);
	is($q->suppressNonmaxSize, $p->suppressNonmaxSize);
}

if (1) {
	my $p = GoodFeaturesToTrackDetector();
	my $q = $p->new();
	is($q->nfeatures, $p->nfeatures);
	is($q->qualityLevel, $p->qualityLevel);
	is($q->minDistance, $p->minDistance);
	is($q->useHarrisDetector, $p->useHarrisDetector);
	is($q->k, $p->k);
}

if (1) {
	my $p = MserFeatureDetector(5, 60, 14400, 0.25, 0.2, 200, 1.01, 0.003, 5);
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

if (1) {
	my $p = DenseFeatureDetector();
	my $q = $p->new();
	is($q->initFeatureScale, $p->initFeatureScale);
	is($q->featureScaleLevels, $p->featureScaleLevels);
	is($q->featureScaleMul, $p->featureScaleMul);
	is($q->initXyStep, $p->initXyStep);
	is($q->initImgBound, $p->initImgBound);
	is($q->varyXyStepWithScale, $p->varyXyStepWithScale);
	is($q->varyImgBoundWithScale, $p->varyImgBoundWithScale);
}
