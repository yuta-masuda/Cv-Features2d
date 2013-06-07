/* -*- mode: text; coding: utf-8; tab-width: 4 -*- */

#include "Cv.inc"

#if _CV_VERSION() >= _VERSION(2,4,0)
#  include "opencv2/nonfree/nonfree.hpp"
#endif

typedef vector<Mat> MatV;
typedef vector<KeyPoint> KeyPointV;
typedef vector<DMatch> DMatchV;
typedef vector<vector<DMatch> > DMatchVV;

static CvMat* matToCvmat(Mat& var)
{
#if 0
	CvMat* cvmat = cvCreateMatHeader(var.rows, var.cols, var.type());
	cvSetData(cvmat, var.data, CV_AUTOSTEP);
	cvIncRefData(cvmat);	   // XXXXX
	return cvmat;
#else
	CvMat cvmat = var;
	return cvCloneMat(&cvmat);
#endif
}

static flann::IndexParams* xsIndexParams(HV* hv)
{
	const int verbose = 0;
	flann::IndexParams* p = new flann::IndexParams();
	HE* he; hv_iterinit(hv);
	while (he = hv_iternext(hv)) {
			SV* sv = hv_iterval(hv, he); int t = SvTYPE(sv);
		I32 len; char* key = hv_iterkey(he, &len);
		if (t == SVt_PV) {
			if (verbose)
				fprintf(stderr, "p.String: %s, %s\n", key, SvPV_nolen(sv));
			p->setString(key, SvPV_nolen(sv));
		} else if (t == SVt_IV) {
			if (strcmp(key, "algorithm") == 0) {
				if (verbose) fprintf(stderr, "p.Algorithm: %d\n", SvIV(sv));
				p->setAlgorithm(SvIV(sv));
			} else {
				if (verbose) fprintf(stderr, "p.Int: %s, %d\n", key, SvIV(sv));
				p->setInt(key, SvIV(sv));
			}
		} else if (t == SVt_NV) {
			if (verbose) fprintf(stderr, "p.Double: %s, %g\n", key, SvNV(sv));
			p->setDouble(key, SvNV(sv));
		} else {
			const char* names[] = {
				"SVt_NULL",
				"SVt_BIND",
				"SVt_IV",
				"SVt_NV",
				/* RV was here, before it was merged with IV.  */
				"SVt_PV",
				"SVt_PVIV",
				"SVt_PVNV",
				"SVt_PVMG",
				"SVt_REGEXP",
				/* PVBM was here, before BIND replaced it.  */
				"SVt_PVGV",
				"SVt_PVLV",
				"SVt_PVAV",
				"SVt_PVHV",
				"SVt_PVCV",
				"SVt_PVFM",
				"SVt_PVIO",
			};
			const char* name = "unknown";
			if (t < SVt_LAST) name = names[t];
			fprintf(stderr, "p.unknown: %s, (%s)\n", key, name);
		}
	}
	return p;
}


MODULE = Cv::Features2d		PACKAGE = Cv::Features2d

# ============================================================
#  Drawing Function of Keypoints and Matches
# ============================================================

MODULE = Cv::Features2d		PACKAGE = Cv::Features2d

void
drawKeypoints(CvArr* image, KeyPointV keypoints, CvScalar color = cvScalarAll(-1), int flags=DrawMatchesFlags::DEFAULT)
CODE:
	Mat outImage = cvarrToMat(image);
	drawKeypoints(cvarrToMat(image), keypoints, outImage, color, flags);


# ============================================================
#  Feature Detection and Description
# ============================================================

MODULE = Cv::Features2d		PACKAGE = Cv::Features2d::Feature2D

void
Feature2D::detectAndCompute(OUTLIST KeyPointV keypoints, OUTLIST CvMat*descriptors, CvArr* image, CvArr* mask = NULL)
CODE:
	Mat _descriptors;
	(*THIS)(cvarrToMat(image), mask? cvarrToMat(mask) : noArray(), keypoints, _descriptors);
	descriptors = matToCvmat(_descriptors);


#if _CV_VERSION() >= _VERSION(2,4,0)

MODULE = Cv::Features2d		PACKAGE = Cv::Features2d::Feature2D::SIFT

SIFT*
SIFT::new(int nfeatures=0, int nOctaveLayers=3, double contrastThreshold=0.04, double edgeThreshold=10, double sigma=1.6)

void
SIFT::DESTROY()

#endif


MODULE = Cv::Features2d		PACKAGE = Cv::Features2d::Feature2D::SURF

SURF*
SURF::new(double hessianThreshold, int nOctaves=4, int nOctaveLayers=2, bool extended=true, bool upright=false)

void
SURF::DESTROY()


#if _CV_VERSION() >= _VERSION(2,4,0)

MODULE = Cv::Features2d		PACKAGE = Cv::Features2d::Feature2D::ORB

ORB*
ORB::new(int nfeatures=500, float scaleFactor=1.2f, int nlevels=8, int edgeThreshold=31, int firstLevel=0, int WTA_K=2, int scoreType=ORB::HARRIS_SCORE, int patchSize=31)

void
ORB::DESTROY()

#endif


#if _CV_VERSION() >= _VERSION(2,4,0)

MODULE = Cv::Features2d		PACKAGE = Cv::Features2d::Feature2D::BRISK

BRISK*
BRISK::new(int thresh=30, int octaves=3, float patternScale=1.0f)

void
BRISK::DESTROY()

#endif

# ============================================================
#  Common Interfaces of Feature Detectors
# ============================================================

MODULE = Cv::Features2d		PACKAGE = Cv::Features2d::FeatureDetector

KeyPointV
FeatureDetector::detect(CvArr* image, CvArr* mask = NULL)
CODE:
	if (mask) {
		THIS->detect(cvarrToMat(image), RETVAL, cvarrToMat(mask));
	} else {
		THIS->detect(cvarrToMat(image), RETVAL);
	}
OUTPUT:
	RETVAL


MODULE = Cv::Features2d		PACKAGE = Cv::Features2d::FeatureDetector::FastFeatureDetector

FastFeatureDetector*
FastFeatureDetector::new(int threshold=1, bool nonmaxSuppression=true)

void
FastFeatureDetector::DESTROY()


MODULE = Cv::Features2d		PACKAGE = Cv::Features2d::FeatureDetector::GoodFeaturesToTrackDetector

GoodFeaturesToTrackDetector*
GoodFeaturesToTrackDetector::new(int maxCorners=1000, double qualityLevel=0.01, double minDistance=1., int blockSize=3, bool useHarrisDetector=false, double k=0.04 )

void
GoodFeaturesToTrackDetector::DESTROY()


MODULE = Cv::Features2d		PACKAGE = Cv::Features2d::FeatureDetector::MserFeatureDetector

MserFeatureDetector*
MserFeatureDetector::new(int delta, int minArea, int maxArea, double maxVariation, double minDiversity, int maxEvolution, double areaThreshold, double minMargin, int edgeBlurSize)

void
MserFeatureDetector::DESTROY()


MODULE = Cv::Features2d		PACKAGE = Cv::Features2d::FeatureDetector::StarFeatureDetector

StarFeatureDetector*
StarFeatureDetector::new(int maxSize=16, int responseThreshold=30, int lineThresholdProjected = 10, int lineThresholdBinarized=8, int suppressNonmaxSize=5)

void
StarFeatureDetector::DESTROY()


#if _CV_VERSION() >= _VERSION(2,4,0)

MODULE = Cv::Features2d		PACKAGE = Cv::Features2d::FeatureDetector::DenseFeatureDetector

DenseFeatureDetector*
DenseFeatureDetector::new(float initFeatureScale=1.f, int featureScaleLevels=1, float featureScaleMul=0.1f, int initXyStep=6, int initImgBound=0, bool varyXyStepWithScale=true, bool varyImgBoundWithScale=false)

void
DenseFeatureDetector::DESTROY()

#endif


# ============================================================
#  Common Interfaces of Descriptor Extractors
# ============================================================

MODULE = Cv::Features2d		PACKAGE = Cv::Features2d::DescriptorExtractor

CvMat*
DescriptorExtractor::compute(CvArr* image, KeyPointV keypoints)
CODE:
	Mat descriptors;
	THIS->compute(cvarrToMat(image), keypoints, descriptors);
	RETVAL = matToCvmat(descriptors);
OUTPUT:
	RETVAL

int
DescriptorExtractor::descriptorSize()

int
DescriptorExtractor::descriptorType()


MODULE = Cv::Features2d		PACKAGE = Cv::Features2d::DescriptorExtractor::BriefDescriptorExtractor

BriefDescriptorExtractor*
BriefDescriptorExtractor::new(int bytes = 32)

void
BriefDescriptorExtractor::DESTROY()



# ============================================================
#  Common Interfaces of Descriptor Matchers
# ============================================================

MODULE = Cv::Features2d		PACKAGE = Cv::Features2d::DescriptorMatcher

DMatchV
DescriptorMatcher::match(CvArr* queryDescriptors, CvArr* trainDescriptors, CvArr* mask = NULL)
CODE:
	if (mask) {
		THIS->match(cvarrToMat(queryDescriptors), cvarrToMat(trainDescriptors), RETVAL, cvarrToMat(mask));
	} else {
		THIS->match(cvarrToMat(queryDescriptors), cvarrToMat(trainDescriptors), RETVAL);
	}
OUTPUT:
	RETVAL

DMatchVV
DescriptorMatcher::knnMatch(CvArr* queryDescriptors, CvArr* trainDescriptors, int k, CvMat* mask = NULL, bool compactResult=false)
CODE:
	THIS->knnMatch(
			cvarrToMat(queryDescriptors), cvarrToMat(trainDescriptors),
			RETVAL, k, mask? cvarrToMat(mask): Mat(), compactResult);
OUTPUT:
	RETVAL

DMatchVV
DescriptorMatcher::radiusMatch(CvArr* queryDescriptors, CvArr* trainDescriptors, float maxDistance, CvArr* mask = NULL, bool compactResult=false)
CODE:
	THIS->radiusMatch(
		cvarrToMat(queryDescriptors), cvarrToMat(trainDescriptors),
		RETVAL, maxDistance, mask? cvarrToMat(mask) : Mat(), compactResult);
OUTPUT:
	RETVAL

MODULE = Cv::Features2d		PACKAGE = Cv::Features2d::DescriptorMatcher::BFMatcher

BFMatcher*
BFMatcher::new(int normType=NORM_L2, bool crossCheck=false)

void
BFMatcher::DESTROY()


MODULE = Cv::Features2d		PACKAGE = Cv::Features2d::DescriptorMatcher::FlannBasedMatcher

FlannBasedMatcher*
FlannBasedMatcher::new(HV* indexParams = NO_INIT, HV* searchParams = NO_INIT)
INIT:
	flann::IndexParams* _indexParams = (items >= 2)?
		xsIndexParams(indexParams) : new flann::KDTreeIndexParams();
	flann::SearchParams* _searchParams = (items >= 3)? (flann::SearchParams*)
		xsIndexParams(searchParams) : new flann::SearchParams();
C_ARGS:	_indexParams, _searchParams

void
FlannBasedMatcher::DESTROY()


MODULE = Cv::Features2d		PACKAGE = Cv::Features2d
