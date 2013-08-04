/* -*- mode: text; coding: utf-8; tab-width: 4 -*- */

#include "Cv.inc"

#if _CV_VERSION() >= _VERSION(2,4,0)
#  include "opencv2/nonfree/nonfree.hpp"
#endif

typedef vector<Mat> MatV;
typedef vector<KeyPoint> KeyPointV;
typedef vector<vector<KeyPoint> > KeyPointVV;
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

static const char* svt_names[] = {
	"SVt_NULL", "SVt_BIND", "SVt_IV", "SVt_NV", "SVt_PV", "SVt_PVIV",
	"SVt_PVNV", "SVt_PVMG", "SVt_REGEXP", "SVt_PVGV", "SVt_PVLV",
	"SVt_PVAV", "SVt_PVHV", "SVt_PVCV", "SVt_PVFM", "SVt_PVIO",
};

static flann::IndexParams* xsIndexParams(HV* hv, const char *var)
{
	flann::IndexParams* p = new flann::IndexParams();
	HE* he; hv_iterinit(hv);
	while (he = hv_iternext(hv)) {
		SV* sv = hv_iterval(hv, he); int t = SvTYPE(sv);
		I32 len; char* key = hv_iterkey(he, &len);
		char* opt = strchr(key, ':'); char key2[strlen(key)+1];
		if (opt && strlen(opt) >= 2) {
			strcpy(key2, key);
			key2[opt - key] = '\0';
			key = key2;
			opt++; // colon
			while (*opt && isspace(*opt)) opt++;
		}
		if (opt && *opt) {
			if (*opt == 'a') {
				p->setString(key, SvPV_nolen(sv));
			} else if (*opt == 'i') {
				p->setInt(key, SvIV(sv));
			} else if (*opt == 'd') {
				p->setDouble(key, SvNV(sv));
			} else if (*opt == 'f') {
				p->setFloat(key, SvNV(sv));
			} else if (*opt == 'b') {
				p->setBool(key, SvIV(sv));
			} else {
				Perl_croak(aTHX_ "can't use \"%s\" to set %s[\"%s\"]",
							opt, var, key);
			}
		} else if (SvROK(sv)) {
			Perl_croak(aTHX_ "can't use ref to set %s[\"%s\"]", var, key);
		} else if (t == SVt_PV) {
			p->setString(key, SvPV_nolen(sv));
		} else if (t == SVt_IV) {
			if (strcmp(key, "algorithm") == 0) {
				p->setAlgorithm(SvIV(sv));
			} else {
				p->setInt(key, SvIV(sv));
			}
		} else if (t == SVt_NV) {
			p->setDouble(key, SvNV(sv));
		} else {
			if (t < SVt_LAST)
				Perl_croak(aTHX_ "can't use %s to set %s[\"%s\"]",
					svt_names[t], var, key);
			else
				Perl_croak(aTHX_ "can't happen to set %s[\"%s\"]", var, key);
		}
	}
	return p;
}


static void dumpIndexParams(flann::IndexParams* p, const char* varName)
{
	SV* sv_verbose = get_sv("Cv::IndexParams::VERBOSE", 0);
	int verbose = SvOK(sv_verbose) && SvIV(sv_verbose);
	if (!verbose) return;
	SV* sv_delim = get_sv(";", 0);
	const char* delim = SvOK(sv_delim) && SvPOK(sv_delim)?
		SvPV_nolen(sv_delim) : "\x1c";
	std::vector<std::string> names;
	std::vector<int> types;
	std::vector<std::string> strValues;
	std::vector<double> numValues;
	p->getAll(names, types, strValues, numValues);
	int n = names.size();
	assert(n == types.size());
	assert(n == strValues.size());
	assert(n == numValues.size());
	for (int i = 0; i < names.size(); i++) {
		warn("%s%s%d=%s%s%d%s%s%s%g\n", varName, delim, i,
			names[i].c_str(), delim,
			types[i], delim,
			strValues[i].c_str(), delim,
			numValues[i]);
	}
}

MODULE = Cv::Features2d		PACKAGE = Cv::Features2d

# ============================================================
#  Drawing Function of Keypoints and Matches
# ============================================================

MODULE = Cv::Features2d		PACKAGE = Cv::Features2d

void
drawKeypoints(CvArr* image, KeyPointV keypoints, CvScalar color = cvScalarAll(-1), int flags=DrawMatchesFlags::DEFAULT)
INIT:
	Mat outImage = cvarrToMat(image);
	flags |= DrawMatchesFlags::DRAW_OVER_OUTIMG;
C_ARGS:
	cvarrToMat(image), keypoints, outImage, color, flags
POSTCALL:
	XSRETURN(1);

CvMat*
drawMatches(CvArr* img1, KeyPointV keypoints1, CvArr* img2, KeyPointV keypoints2, DMatchV matches1to2, CvScalar matchColor = cvScalarAll(-1), CvScalar singlePointColor = cvScalarAll(-1), tiny* matchesMask = NULL, int flags = DrawMatchesFlags::DEFAULT)
INIT:
	vector<char> _matchesMask = matchesMask?
		cvarrToMat(matchesMask) : vector<char>();
CODE:
	Mat outImg;
	drawMatches(cvarrToMat(img1), keypoints1, cvarrToMat(img2), keypoints2, matches1to2, outImg, matchColor, singlePointColor, _matchesMask, flags);
	RETVAL = matToCvmat(outImg);
OUTPUT:
	RETVAL


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

CvMat*
Feature2D::compute(CvArr* image, KeyPointV keypoints)
CODE:
	Mat _descriptors;
	(*THIS)(cvarrToMat(image), noArray(), keypoints, _descriptors, true);
	RETVAL = matToCvmat(_descriptors);
OUTPUT:
	RETVAL

#if _CV_VERSION() >= _VERSION(2,4,0)

MODULE = Cv::Features2d		PACKAGE = Cv::Features2d::Feature2D::SIFT

SIFT*
SIFT::new(int nfeatures=0, int nOctaveLayers=3, double contrastThreshold=0.04, double edgeThreshold=10, double sigma=1.6)
INIT:
	if (sv_isobject(ST(0)) && (SvTYPE(SvRV(ST(0))) == SVt_PVMG)) {
		SIFT* THIS = (SIFT*)SvIV((SV*)SvRV(ST(0)));
		if (items < 2) nfeatures = THIS->get<int>("nFeatures");
		if (items < 3) nOctaveLayers = THIS->get<int>("nOctaveLayers");
		if (items < 4) contrastThreshold = THIS->get<double>("contrastThreshold");
		if (items < 5) edgeThreshold = THIS->get<double>("edgeThreshold");
		if (items < 6) sigma = THIS->get<double>("sigma");
	}

void
SIFT::DESTROY()

#endif


MODULE = Cv::Features2d		PACKAGE = Cv::Features2d::Feature2D::SURF

SURF*
SURF::new(double hessianThreshold=NO_INIT, int nOctaves=4, int nOctaveLayers=2, bool extended=true, bool upright=false)
INIT:
	if (sv_isobject(ST(0)) && (SvTYPE(SvRV(ST(0))) == SVt_PVMG)) {
		SURF* THIS = (SURF*)SvIV((SV*)SvRV(ST(0)));
		if (items < 2) hessianThreshold = THIS->get<double>("hessianThreshold");
		if (items < 3) nOctaves = THIS->get<int>("nOctaves");
		if (items < 4) nOctaveLayers = THIS->get<int>("nOctaveLayers");
		if (items < 5) extended = THIS->get<bool>("extended");
		if (items < 6) upright = THIS->get<bool>("upright");
	} else if (items < 2) {
		croak_xs_usage(cv,  "CLASS, hessianThreshold, nOctaves=4, nOctaveLayers=2, extended=true, upright=false");
	}

void
SURF::DESTROY()


#if _CV_VERSION() >= _VERSION(2,4,0)

MODULE = Cv::Features2d		PACKAGE = Cv::Features2d::Feature2D::ORB

ORB*
ORB::new(int nfeatures=500, float scaleFactor=1.2f, int nlevels=8, int edgeThreshold=31, int firstLevel=0, int WTA_K=2, int scoreType=ORB::HARRIS_SCORE, int patchSize=31)
INIT:
	if (sv_isobject(ST(0)) && (SvTYPE(SvRV(ST(0))) == SVt_PVMG)) {
		ORB* THIS = (ORB*)SvIV((SV*)SvRV(ST(0)));
		if (items < 2) nfeatures = THIS->get<int>("nFeatures");
		if (items < 3) scaleFactor = THIS->get<double>("scaleFactor");
		if (items < 4) nlevels = THIS->get<int>("nLevels");
		if (items < 5) edgeThreshold = THIS->get<int>("edgeThreshold");
		if (items < 6) firstLevel = THIS->get<int>("firstLevel");
		if (items < 7) WTA_K = THIS->get<int>("WTA_K");
		if (items < 8) scoreType = THIS->get<int>("scoreType");
		if (items < 9) patchSize = THIS->get<int>("patchSize");
	}

void
ORB::DESTROY()

#endif


#if _CV_VERSION() >= _VERSION(2,4,0)

MODULE = Cv::Features2d		PACKAGE = Cv::Features2d::Feature2D::BRISK

BRISK*
BRISK::new(int thresh=30, int octaves=3, float patternScale=1.0f)
INIT:
	if (sv_isobject(ST(0)) && (SvTYPE(SvRV(ST(0))) == SVt_PVMG)) {
		BRISK* THIS = (BRISK*)SvIV((SV*)SvRV(ST(0)));
		if (items < 2) thresh = THIS->get<int>("thres");
		if (items < 3) octaves = THIS->get<int>("octaves");
		// if (items < 4) patternScale = THIS->get<double>("patternScale");
	}

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
	THIS->detect(cvarrToMat(image), RETVAL, mask? cvarrToMat(mask) : Mat());
OUTPUT:
	RETVAL

#if _CV_VERSION() >= _VERSION(2,4,1)

SV*
name(FeatureDetector* THIS)
CODE:
	string s = THIS->name();
	RETVAL = newSVpvn(s.c_str(), s.size());
OUTPUT:
	RETVAL

#endif

MODULE = Cv::Features2d		PACKAGE = Cv::Features2d::FeatureDetector::FastFeatureDetector

FastFeatureDetector*
FastFeatureDetector::new(int threshold=1, bool nonmaxSuppression=true)
INIT:
	if (sv_isobject(ST(0)) && (SvTYPE(SvRV(ST(0))) == SVt_PVMG)) {
		FastFeatureDetector* THIS = (FastFeatureDetector*)SvIV((SV*)SvRV(ST(0)));
		if (items < 2) threshold = THIS->get<int>("threshold");
		if (items < 3) nonmaxSuppression = THIS->get<bool>("nonmaxSuppression");
	}

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
INIT:
	if (sv_isobject(ST(0)) && (SvTYPE(SvRV(ST(0))) == SVt_PVMG)) {
		StarFeatureDetector* THIS = (StarFeatureDetector*)SvIV((SV*)SvRV(ST(0)));
		if (items < 2) maxSize = THIS->get<int>("maxSize");
		if (items < 3) responseThreshold = THIS->get<int>("responseThreshold");
		if (items < 4) lineThresholdProjected = THIS->get<int>("lineThresholdProjected");
		if (items < 5) lineThresholdBinarized = THIS->get<int>("lineThresholdBinarized");
		if (items < 6) suppressNonmaxSize = THIS->get<int>("suppressNonmaxSize");
	}

void
StarFeatureDetector::DESTROY()


#if _CV_VERSION() >= _VERSION(2,4,0)

MODULE = Cv::Features2d		PACKAGE = Cv::Features2d::FeatureDetector::DenseFeatureDetector

DenseFeatureDetector*
DenseFeatureDetector::new(float initFeatureScale=1.f, int featureScaleLevels=1, float featureScaleMul=0.1f, int initXyStep=6, int initImgBound=0, bool varyXyStepWithScale=true, bool varyImgBoundWithScale=false)

void
DenseFeatureDetector::DESTROY()

#endif


MODULE = Cv::Features2d		PACKAGE = Cv::Features2d::FeatureDetector::GridAdaptedFeatureDetector

GridAdaptedFeatureDetector*
GridAdaptedFeatureDetector::new(FeatureDetector *detector, int maxTotalKeypoints, int gridRows=4, int gridCols=4)

void
GridAdaptedFeatureDetector::DESTROY()

MODULE = Cv::Features2d		PACKAGE = Cv::Features2d::FeatureDetector::PyramidAdaptedFeatureDetector

PyramidAdaptedFeatureDetector*
PyramidAdaptedFeatureDetector::new(FeatureDetector *detector, int levels=2)

void
PyramidAdaptedFeatureDetector::DESTROY()


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

SV*
name(DescriptorExtractor* THIS)
CODE:
	string s = THIS->name();
	RETVAL = newSVpvn(s.c_str(), s.size());
OUTPUT:
	RETVAL


MODULE = Cv::Features2d		PACKAGE = Cv::Features2d::DescriptorExtractor::BriefDescriptorExtractor

BriefDescriptorExtractor*
BriefDescriptorExtractor::new(int bytes = 32)
INIT:
	if (sv_isobject(ST(0)) && (SvTYPE(SvRV(ST(0))) == SVt_PVMG)) {
		BriefDescriptorExtractor* THIS = (BriefDescriptorExtractor*)SvIV((SV*)SvRV(ST(0)));
		if (items < 2) bytes = THIS->get<int>("bytes");
	}

void
BriefDescriptorExtractor::DESTROY()


#if _CV_VERSION() >= _VERSION(2,4,2)

MODULE = Cv::Features2d		PACKAGE = Cv::Features2d::DescriptorExtractor::FREAK

# C++: FREAK::FREAK(bool orientationNormalized=true, bool scaleNormalized=true, float patternScale=22.0f, int nOctaves=4, const vector<int>& selectedPairs=vector<int>())

FREAK*
FREAK::new(bool orientationNormalized = true, bool scaleNormalized = true, float patternScale = 22.0f, int nOctaves = 4)

void
FREAK::DESTROY()

#endif


MODULE = Cv::Features2d		PACKAGE = Cv::Features2d::DescriptorExtractor::OpponentColorDescriptorExtractor

DescriptorExtractor*
OpponentColorDescriptorExtractor::new(DescriptorExtractor* dextractor)

void
OpponentColorDescriptorExtractor::DESTROY()


# ============================================================
#  Common Interfaces of Descriptor Matchers
# ============================================================

MODULE = Cv::Features2d		PACKAGE = Cv::Features2d::DescriptorMatcher

DMatchV
DescriptorMatcher::match(CvArr* queryDescriptors, CvArr* trainDescriptors, CvArr* mask = NULL)
CODE:
	THIS->match(
		cvarrToMat(queryDescriptors), cvarrToMat(trainDescriptors),
		RETVAL, mask? cvarrToMat(mask): Mat());
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
		xsIndexParams(indexParams, "indexParams") :
		new flann::KDTreeIndexParams();
	flann::SearchParams* _searchParams = (items >= 3)?
		(flann::SearchParams*) xsIndexParams(searchParams, "searchParams") :
		new flann::SearchParams();
	dumpIndexParams(_indexParams, "indexParams");
	dumpIndexParams(_searchParams, "searchParams");
C_ARGS:	_indexParams, _searchParams

void
FlannBasedMatcher::DESTROY()

MODULE = Cv::Features2d		PACKAGE = Cv::Features2d
