# -*- mode: perl; coding: utf-8; tab-width: 4 -*-

use strict;
use warnings;
use Test::More qw(no_plan);
# use Test::More;
use Test::Exception;
BEGIN { use_ok('Cv', -nonfree) }
BEGIN { use_ok('Cv::Features2d', qw(:all)) }

use constant { true => 1, false => '' };

if (1) {
	my $p = SIFT(
		my $nfeatures = 100,
		my $nOctaveLayers = 3,
		my $contrastThreshold = 0.04,
		my $edgeThreshold = 10,
		my $sigma = 1.6,
		);
	ok($p);
	is($p->nFeatures, $nfeatures, 'nFeatures');
	is($p->nOctaveLayers, $nOctaveLayers, 'nOctaveLayers');
	is($p->contrastThreshold, $contrastThreshold, 'contrastThreshold');
	is($p->edgeThreshold, $edgeThreshold, 'edgeThreshold');
	is($p->sigma, $sigma, 'sigma');
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
	my $p = SURF(
		my $hessianThreshold = 101,
		my $nOctaves = 4,
		my $nOctaveLayers = 2,
		my $extended = 1,
		my $upright = false,
		);
	ok($p);
	is($p->hessianThreshold, $hessianThreshold, 'hessianThreshold');
	is($p->nOctaves, $nOctaves, 'nOctaves');
	is($p->nOctaveLayers, $nOctaveLayers, 'nOctaveLayers');
	is($p->extended, $extended, 'extended');
	is($p->upright, $upright, 'upright');
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
	my $p = ORB(
		my $nfeatures = 500,
		my $scaleFactor = 1.2,
		my $nlevels = 8,
		my $edgeThreshold = 31,
		my $firstLevel = 0,
		my $WTA_K = 2,
		my $scoreType = 0,
		my $patchSize = 31,
		);
	ok($p);
	is($p->nFeatures, $nfeatures, 'nFeatures');
	is($p->scaleFactor, $scaleFactor, 'scaleFactor');
	is($p->nLevels, $nlevels, 'nLevels');
	is($p->firstLevel, $firstLevel, 'firstLevel');
	is($p->edgeThreshold, $edgeThreshold, 'edgeThreshold');
	is($p->WTA_K, $WTA_K, 'WTA_K');
	is($p->scoreType, $scoreType, 'scoreType');
	is($p->patchSize, $patchSize, 'patchSize');
	lives_ok { $p->name };
	is($Cv::Features2d::CLASS{$p->name}, ref $p);
	my $q = $p->new();
	is($q->nFeatures, $p->nFeatures);
	is($q->scaleFactor, $p->scaleFactor);
	is($q->nLevels, $p->nLevels);
	is($q->firstLevel, $p->firstLevel);
	is($q->edgeThreshold, $p->edgeThreshold);
	is($q->WTA_K, $p->WTA_K);
	is($q->scoreType, $p->scoreType);
	is($q->patchSize, $p->patchSize);
}

if (4) {
	my $p = BRISK(
		my $thresh = 31,
		my $octaves = 4,
		my $patternScale = 1.2,
		);
	ok($p);
	is($p->thres, $thresh, 'thres');
	is($p->octaves, $octaves, 'octaves');
	# is($p->patternScale, $patternScale, 'patternScale');
	lives_ok { $p->name };
	is($Cv::Features2d::CLASS{$p->name}, ref $p);
	my $q = $p->new();
	is($q->thres, $p->thres);
	is($q->octaves, $p->octaves);
	# is($q->patternScale, $p->patternScale);
}

if (5) {
	my $p = FastFeatureDetector(
		my $threshold = 1,
		my $nonmaxSuppression = true,
		my $type = 2,
		);
	ok($p);
	is($p->threshold, $threshold, 'threshold');
	is($p->nonmaxSuppression, $nonmaxSuppression, 'nonmaxSuppression');
	# is($p->type, $type, 'type');
	lives_ok { $p->name };
	is($Cv::Features2d::CLASS{$p->name}, ref $p);
	my $q = $p->new();
	is($q->threshold, $p->threshold);
	is($q->nonmaxSuppression, $p->nonmaxSuppression);
	# is($q->type, $p->type);
}

if (6) {
	my $p = StarFeatureDetector(
		my $maxSize = 16,
		my $responseThreshold = 30,
		my $lineThresholdProjected = 10,
		my $lineThresholdBinarized = 8,
		my $suppressNonmaxSize = 5,
		);
	ok($p);
	is($p->maxSize, $maxSize, 'maxSize');
	is($p->responseThreshold, $responseThreshold, 'responseThreshold');
	is($p->lineThresholdProjected, $lineThresholdProjected, 'lineThresholdProjected');
	is($p->lineThresholdBinarized, $lineThresholdBinarized, 'lineThresholdBinarized');
	is($p->suppressNonmaxSize, $suppressNonmaxSize, 'suppressNonmaxSize');
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
	my $p = GoodFeaturesToTrackDetector(
		my $maxCorners = 101,
		my $qualityLevel = 0.03,
		my $minDistance = 4,
		my $blockSize = 3,
		my $useHarrisDetector = 1,
		my $k = 0.06);
	ok($p);
	lives_ok { $p->name };
	is($Cv::Features2d::CLASS{$p->name}, ref $p);
	is($p->nfeatures, $maxCorners);
	is($p->qualityLevel, $qualityLevel);
	is($p->minDistance, $minDistance);
	# is($p->blockSize, $blockSize);
	is($p->useHarrisDetector, $useHarrisDetector);
	is($p->k, $k);
	my $q = $p->new();
	is($q->nfeatures, $p->nfeatures);
	is($q->qualityLevel, $p->qualityLevel);
	is($q->minDistance, $p->minDistance);
	# is($q->blockSize, $p->blockSize);
	is($q->useHarrisDetector, $p->useHarrisDetector);
	is($q->k, $p->k);
}

if (8) {
	my $p = MserFeatureDetector(
		my $delta = 5,
		my $minArea = 60,
		my $maxArea = 14400,
		my $maxVariation = 0.25,
		my $minDiversity = 0.2,
		my $maxEvolution = 200,
		my $areaThreshold = 1.01,
		my $minMargin = 0.003,
		my $edgeBlurSize = 5,
		);
	ok($p);
	is($p->delta, $delta, 'delta');
	is($p->minArea, $minArea, 'minArea');
	is($p->maxArea, $maxArea, 'maxArea');
	is($p->maxVariation, $maxVariation, 'maxVariation');
	is($p->minDiversity, $minDiversity, 'minDiversity');
	is($p->maxEvolution, $maxEvolution, 'maxEvolution');
	is($p->areaThreshold, $areaThreshold, 'areaThreshold');
	is($p->minMargin, $minMargin, 'minMargin');
	is($p->edgeBlurSize, $edgeBlurSize, 'edgeBlurSize');
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
	my $p = DenseFeatureDetector(
		my $initFeatureScale = 1.0,
		my $featureScaleLevels = 1,
		my $featureScaleMul = 0.1,
		my $initXyStep = 6,
		my $initImgBound = 0,
		my $varyXyStepWithScale = true,
		my $varyImgBoundWithScale = false,
		);
	ok($p);
	is($p->initFeatureScale, $initFeatureScale, 'initFeatureScale');
	is($p->featureScaleLevels, $featureScaleLevels, 'featureScaleLevels');
	is($p->featureScaleMul, $featureScaleMul, 'featureScaleMul');
	is($p->initXyStep, $initXyStep, 'initXyStep');
	is($p->initImgBound, $initImgBound, 'initImgBound');
	is($p->varyXyStepWithScale, $varyXyStepWithScale, 'varyXyStepWithScale');
	is($p->varyImgBoundWithScale, $varyImgBoundWithScale, 'varyImgBoundWithScale');
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
	my $p = BriefDescriptorExtractor(
		my $bytes = 32,
		);
	ok($p);
	is($p->bytes, $bytes, 'bytes');
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
