/* -*- mode: text; coding: utf-8; tab-width: 4 -*- */

#include "Cv.inc"
#include "opencv2/nonfree/nonfree.hpp"

static int HvIV(HV* hv, const char* name, int value)
{
	SV** p = hv_fetch(hv, name, strlen(name), 0);
	if (p) value = SvIV(*p);
	return value;
}

static double HvNV(HV* hv, const char* name, double value)
{
	SV** p = hv_fetch(hv, name, strlen(name), 0);
	if (p) value = SvNV(*p);
	return value;
}


MODULE = Cv::FeatureDetector		PACKAGE = Cv::FeatureDetector

AV*
FeatureDetector::detect(CvArr* image, CvArr* mask = NULL)
CODE:
	Mat _image = cv::cvarrToMat(image);
	vector<KeyPoint> _keypoints;
	if (mask) {
		Mat _mask = cvarrToMat(mask);
		THIS->detect(_image, _keypoints, _mask);
	} else {
		THIS->detect(_image, _keypoints);
	}
	RETVAL = newAV();
	int n = (int)_keypoints.size();
	for (int i = 0; i < n; i++) {
		AV* av_kpt = newAV();
		AV* av_pt = newAV();
		av_push(av_pt, newSVnv(_keypoints[i].pt.x));
		av_push(av_pt, newSVnv(_keypoints[i].pt.y));
		av_push(av_kpt, newRV_inc(sv_2mortal((SV*)av_pt)));
		av_push(av_kpt, newSVnv(_keypoints[i].size));
		av_push(av_kpt, newSVnv(_keypoints[i].angle));
		av_push(av_kpt, newSVnv(_keypoints[i].response));
		av_push(av_kpt, newSViv(_keypoints[i].octave));
		av_push(av_kpt, newSViv(_keypoints[i].class_id));
		av_push(RETVAL, newRV_inc(sv_2mortal((SV*)av_kpt)));
	}
OUTPUT:
	RETVAL

MODULE = Cv::FeatureDetector		PACKAGE = Cv::FeatureDetector::FAST

FastFeatureDetector*
FastFeatureDetector::new(int threshold=1, bool nonmaxSuppression=true)

void
FastFeatureDetector::DESTROY()


MODULE = Cv::FeatureDetector		PACKAGE = Cv::FeatureDetector::STAR

StarFeatureDetector*
StarFeatureDetector::new(int maxSize=16, int responseThreshold=30, int lineThresholdProjected = 10, int lineThresholdBinarized=8, int suppressNonmaxSize=5)

void
StarFeatureDetector::DESTROY()


MODULE = Cv::FeatureDetector		PACKAGE = Cv::FeatureDetector::SIFT

SIFT*
SIFT::new(int nfeatures=0, int nOctaveLayers=3, double contrastThreshold=0.04, double edgeThreshold=10, double sigma=1.6)

void
SIFT::DESTROY()


MODULE = Cv::FeatureDetector		PACKAGE = Cv::FeatureDetector::SURF

SURF*
SURF::new(double hessianThreshold, int nOctaves=4, int nOctaveLayers=2, bool extended=true, bool upright=false)

void
SURF::DESTROY()


MODULE = Cv::FeatureDetector		PACKAGE = Cv::FeatureDetector::ORB

ORB*
ORB::new(int nfeatures=500, float scaleFactor=1.2f, int nlevels=8, int edgeThreshold=31, int firstLevel=0, int WTA_K=2, int scoreType=ORB::HARRIS_SCORE, int patchSize=31)

void
ORB::DESTROY()


MODULE = Cv::FeatureDetector		PACKAGE = Cv::FeatureDetector::BRISK

BRISK*
BRISK::new(int thresh=30, int octaves=3, float patternScale=1.0f)

void
BRISK::DESTROY()


MODULE = Cv::FeatureDetector		PACKAGE = Cv::FeatureDetector::GFTT

GoodFeaturesToTrackDetector*
GoodFeaturesToTrackDetector::new(int maxCorners=1000, double qualityLevel=0.01, double minDistance=1., int blockSize=3, bool useHarrisDetector=false, double k=0.04 )

void
GoodFeaturesToTrackDetector::DESTROY()


MODULE = Cv::FeatureDetector		PACKAGE = Cv::FeatureDetector::MSER

MserFeatureDetector*
MserFeatureDetector::new(int delta, int minArea, int maxArea, double maxVariation, double minDiversity, int maxEvolution, double areaThreshold, double minMargin, int edgeBlurSize)

void
MserFeatureDetector::DESTROY()


MODULE = Cv::FeatureDetector		PACKAGE = Cv::FeatureDetector::Dense

DenseFeatureDetector*
DenseFeatureDetector::new(float initFeatureScale=1.f, int featureScaleLevels=1, float featureScaleMul=0.1f, int initXyStep=6, int initImgBound=0, bool varyXyStepWithScale=true, bool varyImgBoundWithScale=false)

void
DenseFeatureDetector::DESTROY()

MODULE = Cv::FeatureDetector		PACKAGE = Cv::DescriptorExtractor

DescriptorExtractor*
create(const char* CLASS, const char* descriptorExtractorType)
CODE:
	RETVAL = DescriptorExtractor::create(descriptorExtractorType);
OUTPUT:
	RETVAL

void
DescriptorExtractor::DESTROY()

CvMat*
DescriptorExtractor::compute(CvMat* image, AV* keypoints)
CODE:
	Mat _image = cvarrToMat(image);
	vector<KeyPoint> _keypoints;
	Mat _descriptors;
	int n = av_len(keypoints) + 1;
	for (int i = 0; i < n; i++) {
		SV* sv_keypoint = (SV*)*av_fetch(keypoints, i, 0);
		AV* av_keypoint = (AV*)SvRV(sv_keypoint);
		SV* sv_pt       = (SV*)*av_fetch(av_keypoint, 0, 0);
		SV* sv_size     = (SV*)*av_fetch(av_keypoint, 1, 0);
		SV* sv_angle    = (SV*)*av_fetch(av_keypoint, 2, 0);
		SV* sv_response = (SV*)*av_fetch(av_keypoint, 3, 0);
		SV* sv_octave   = (SV*)*av_fetch(av_keypoint, 4, 0);
		SV* sv_classId  = (SV*)*av_fetch(av_keypoint, 5, 0);
		AV* av_pt       = (AV*)SvRV(sv_pt);
		SV* sv_pt_x     = (SV*)*av_fetch(av_pt, 0, 0);
		SV* sv_pt_y     = (SV*)*av_fetch(av_pt, 1, 0);
		_keypoints.push_back(
			KeyPoint(
				Point2f(SvNV(sv_pt_x), SvNV(sv_pt_y)),
				SvNV(sv_size), SvNV(sv_angle), SvNV(sv_response),
				SvNV(sv_octave), SvNV(sv_classId)
				)
			);
	}
	THIS->compute(_image, _keypoints, _descriptors);
	RETVAL = cvCreateMatHeader(
		_descriptors.rows, _descriptors.cols, _descriptors.flags);
	cvSetData(RETVAL, _descriptors.data, CV_AUTOSTEP);
OUTPUT:
	RETVAL



MODULE = Cv::FeatureDetector		PACKAGE = Cv::DescriptorExtractor::BRIEF

BriefDescriptorExtractor*
BriefDescriptorExtractor::new(int bytes = 32)

void
BriefDescriptorExtractor::DESTROY()


MODULE = Cv::FeatureDetector		PACKAGE = Cv::FeatureDetector
