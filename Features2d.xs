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

FeatureDetector*
create(const char* CLASS, const char* detectorType)
CODE:
	Ptr<FeatureDetector> THIS = FeatureDetector::create(detectorType);
	if (THIS.empty()) XSRETURN_UNDEF;
	RETVAL = THIS; THIS.addref();
OUTPUT:
	RETVAL

void
FeatureDetector::DESTROY()
CODE:
	((Ptr<FeatureDetector>)THIS).release();


MODULE = Cv::Features2d		PACKAGE = Cv::Features2d::FeatureDetector::PyramidAdaptedFeatureDetector

PyramidAdaptedFeatureDetector*
PyramidAdaptedFeatureDetector::new(VOID* detector, int levels=2)
C_ARGS: (FeatureDetector*)detector, levels

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

DescriptorExtractor*
create(const char* CLASS, const char* descriptorExtractorType)
CODE:
	Ptr<DescriptorExtractor> THIS = DescriptorExtractor::create(descriptorExtractorType);
	if (THIS.empty()) XSRETURN_UNDEF;
	RETVAL = THIS; THIS.addref();
OUTPUT:
	RETVAL

void
DescriptorExtractor::DESTROY()
CODE:
	((Ptr<DescriptorExtractor>)THIS).release();


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

MODULE = Cv::Features2d		PACKAGE = Cv::Features2d::Algorithm

SV*
name(VOID* THIS)
CODE:
	string s = ((Algorithm *)THIS)->name();
	RETVAL = newSVpvn(s.c_str(), s.size());
OUTPUT:
	RETVAL

void
Algorithm::set_int(const char* name, int value)
CODE:
	THIS->set(name, value);

int
Algorithm::get_int(const char* name)
CODE:
	RETVAL = THIS->get<int>(name);
OUTPUT:
	RETVAL

void
Algorithm::set_double(const char* name, double value)
CODE:
	THIS->set(name, value);

double
Algorithm::get_double(const char* name)
CODE:
	RETVAL = THIS->get<double>(name);
OUTPUT:
	RETVAL

void
Algorithm::set_bool(const char* name, bool value)
CODE:
	THIS->set(name, value);

bool
Algorithm::get_bool(const char* name)
CODE:
	RETVAL = THIS->get<bool>(name);
OUTPUT:
	RETVAL

void
Algorithm::set_algorithm(const char* name, VOID* value)
CODE:
	THIS->set(name, (Ptr<Algorithm>)(Algorithm*)value);

VOID*
Algorithm::get_algorithm(const char* name)
CODE:
	RETVAL = (VOID*)THIS->get<Algorithm>(name);
	((Ptr<Algorithm>)(Algorithm*)RETVAL).addref();
OUTPUT:
	RETVAL

MODULE = Cv::Features2d		PACKAGE = Cv::Features2d
