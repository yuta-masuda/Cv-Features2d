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
	CvMat* cvmat = cvCreateMatHeader(var.rows, var.cols, var.type());
	cvSetData(cvmat, var.data, CV_AUTOSTEP);
	var.addref();
	return cvmat;
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


// ============================================================

class XsFastAdjuster: public FastAdjuster {
public:
	XsFastAdjuster(String CLASS, int init_thresh=20, bool nonmax=true, int min_thresh=1, int max_thresh=200);

	virtual void tooFew(int minv, int n_detected);
	virtual void tooMany(int maxv, int n_detected);
	virtual bool good() const;

	virtual Ptr<AdjusterAdapter> clone() const;

protected:
	virtual void detectImpl(const Mat& image, vector<KeyPoint>& keypoints, const Mat& mask=Mat()) const;
	int thresh_;
	bool nonmax_;
	int init_thresh_, min_thresh_, max_thresh_;

	String CLASS_;
	SV* sv_thresh;
	SV* sv_init_thresh;
	SV* sv_min_thresh;
	SV* sv_max_thresh;
};

XsFastAdjuster::XsFastAdjuster(String CLASS, int init_thresh, bool nonmax, int min_thresh, int max_thresh):
	CLASS_(CLASS),
	thresh_(init_thresh), nonmax_(nonmax), init_thresh_(init_thresh),
	min_thresh_(min_thresh), max_thresh_(max_thresh)
{
	int n = CLASS_.find("=");
	if (n >= 0) CLASS_ = CLASS_.substr(0, n);

	sv_thresh      = get_sv((CLASS_ + "::THRESH"     ).c_str(), GV_ADD);
	sv_init_thresh = get_sv((CLASS_ + "::INIT_THRESH").c_str(), GV_ADD);
	sv_min_thresh  = get_sv((CLASS_ + "::MIN_THRESH" ).c_str(), GV_ADD);
	sv_max_thresh  = get_sv((CLASS_ + "::MAX_THRESH" ).c_str(), GV_ADD);

	sv_setsv(sv_thresh,      sv_2mortal(newSViv(init_thresh_)));
	sv_setsv(sv_init_thresh, sv_2mortal(newSViv(init_thresh_)));
	sv_setsv(sv_min_thresh,  sv_2mortal(newSViv(min_thresh_ )));
	sv_setsv(sv_max_thresh,  sv_2mortal(newSViv(max_thresh_ )));
}

void XsFastAdjuster::detectImpl(const Mat& image, vector<KeyPoint>& keypoints, const Mat& mask) const
{
	FastFeatureDetector(thresh_, nonmax_).detect(image, keypoints, mask);
}

void XsFastAdjuster::tooFew(int min, int n_detected)
{
	dSP;
	ENTER;
	SAVETMPS;
	PUSHMARK(SP);
	XPUSHs(sv_2mortal(newSViv(min)));
	XPUSHs(sv_2mortal(newSViv(n_detected)));
	PUTBACK;
	call_pv((CLASS_ + "::tooFew").c_str(), 0);
	FREETMPS;
	LEAVE;
	thresh_ = SvIV(sv_thresh);
}

void XsFastAdjuster::tooMany(int max, int n_detected)
{
	dSP;
	ENTER;
	SAVETMPS;
	PUSHMARK(SP);
	XPUSHs(sv_2mortal(newSViv(max)));
	XPUSHs(sv_2mortal(newSViv(n_detected)));
	PUTBACK;
	call_pv((CLASS_ + "::tooMany").c_str(), 0);
	FREETMPS;
	LEAVE;
	thresh_ = SvIV(sv_thresh);
}

bool XsFastAdjuster::good() const
{
	dSP;
	ENTER;
	SAVETMPS;
	PUSHMARK(SP);
	// PUTBACK;
	int result = call_pv((CLASS_ + "::good").c_str(), 0);
	FREETMPS;
	LEAVE;
	return result;
}

Ptr<AdjusterAdapter> XsFastAdjuster::clone() const
{
    Ptr<AdjusterAdapter> cloned_obj = new XsFastAdjuster(
		CLASS_, init_thresh_, nonmax_, min_thresh_, max_thresh_);
    return cloned_obj;
}

// ============================================================

class XsStarAdjuster: public StarAdjuster
{
public:
    XsStarAdjuster(String CLASS, double initial_thresh=30.0, double min_thresh=2., double max_thresh=200.);

    virtual void tooFew(int minv, int n_detected);
    virtual void tooMany(int maxv, int n_detected);
    virtual bool good() const;

    virtual Ptr<AdjusterAdapter> clone() const;

protected:
    virtual void detectImpl( const Mat& image, vector<KeyPoint>& keypoints, const Mat& mask=Mat() ) const;

    double thresh_, init_thresh_, min_thresh_, max_thresh_;
	String CLASS_;
	SV* sv_thresh;
	SV* sv_init_thresh;
	SV* sv_min_thresh;
	SV* sv_max_thresh;
};

XsStarAdjuster::XsStarAdjuster(String CLASS, double initial_thresh, double min_thresh, double max_thresh) :
	CLASS_(CLASS),
    thresh_(initial_thresh), init_thresh_(initial_thresh),
    min_thresh_(min_thresh), max_thresh_(max_thresh)
{
	int n = CLASS_.find("=");
	if (n >= 0) CLASS_ = CLASS_.substr(0, n);

	sv_thresh      = get_sv((CLASS_ + "::THRESH"     ).c_str(), GV_ADD);
	sv_init_thresh = get_sv((CLASS_ + "::INIT_THRESH").c_str(), GV_ADD);
	sv_min_thresh  = get_sv((CLASS_ + "::MIN_THRESH" ).c_str(), GV_ADD);
	sv_max_thresh  = get_sv((CLASS_ + "::MAX_THRESH" ).c_str(), GV_ADD);

	sv_setsv(sv_thresh,      sv_2mortal(newSVnv(init_thresh_)));
	sv_setsv(sv_init_thresh, sv_2mortal(newSVnv(init_thresh_)));
	sv_setsv(sv_min_thresh,  sv_2mortal(newSVnv(min_thresh_ )));
	sv_setsv(sv_max_thresh,  sv_2mortal(newSVnv(max_thresh_ )));
}

void XsStarAdjuster::detectImpl(const Mat& image, vector<KeyPoint>& keypoints, const Mat& mask) const
{
	StarFeatureDetector detector_tmp(16, cvRound(thresh_), 10, 8, 3);
    detector_tmp.detect(image, keypoints, mask);
}

void XsStarAdjuster::tooFew(int minv, int n_detected)
{
	dSP;
	ENTER;
	SAVETMPS;
	PUSHMARK(SP);
	XPUSHs(sv_2mortal(newSViv(minv)));
	XPUSHs(sv_2mortal(newSViv(n_detected)));
	PUTBACK;
	call_pv((CLASS_ + "::tooFew").c_str(), 0);
	FREETMPS;
	LEAVE;
	thresh_ = SvNV(sv_thresh);
}

void XsStarAdjuster::tooMany(int maxv, int n_detected)
{
	dSP;
	ENTER;
	SAVETMPS;
	PUSHMARK(SP);
	XPUSHs(sv_2mortal(newSViv(maxv)));
	XPUSHs(sv_2mortal(newSViv(n_detected)));
	PUTBACK;
	call_pv((CLASS_ + "::tooMany").c_str(), 0);
	FREETMPS;
	LEAVE;
	thresh_ = SvNV(sv_thresh);
}

bool XsStarAdjuster::good() const
{
	dSP;
	ENTER;
	SAVETMPS;
	PUSHMARK(SP);
	// PUTBACK;
	int result = call_pv((CLASS_ + "::good").c_str(), 0);
	FREETMPS;
	LEAVE;
	return result;
}

Ptr<AdjusterAdapter> XsStarAdjuster::clone() const
{
    Ptr<AdjusterAdapter> cloned_obj = new XsStarAdjuster(
		CLASS_, init_thresh_, min_thresh_, max_thresh_);
    return cloned_obj;
}

// ============================================================

class XsSurfAdjuster: public SurfAdjuster
{
public:
    XsSurfAdjuster(String CLASS, double initial_thresh=400.f, double min_thresh=2, double max_thresh=1000 );

    virtual void tooFew(int minv, int n_detected);
    virtual void tooMany(int maxv, int n_detected);
    virtual bool good() const;

    virtual Ptr<AdjusterAdapter> clone() const;

protected:
    virtual void detectImpl( const Mat& image, vector<KeyPoint>& keypoints, const Mat& mask=Mat() ) const;

    double thresh_, init_thresh_, min_thresh_, max_thresh_;

	String CLASS_;
	SV* sv_thresh;
	SV* sv_init_thresh;
	SV* sv_min_thresh;
	SV* sv_max_thresh;
};

XsSurfAdjuster::XsSurfAdjuster(String CLASS, double initial_thresh, double min_thresh, double max_thresh) :
	CLASS_(CLASS),
    thresh_(initial_thresh), init_thresh_(initial_thresh),
    min_thresh_(min_thresh), max_thresh_(max_thresh)
{
	int n = CLASS_.find("=");
	if (n >= 0) CLASS_ = CLASS_.substr(0, n);

	sv_thresh      = get_sv((CLASS_ + "::THRESH"     ).c_str(), GV_ADD);
	sv_init_thresh = get_sv((CLASS_ + "::INIT_THRESH").c_str(), GV_ADD);
	sv_min_thresh  = get_sv((CLASS_ + "::MIN_THRESH" ).c_str(), GV_ADD);
	sv_max_thresh  = get_sv((CLASS_ + "::MAX_THRESH" ).c_str(), GV_ADD);

	sv_setsv(sv_thresh,      sv_2mortal(newSVnv(init_thresh_)));
	sv_setsv(sv_init_thresh, sv_2mortal(newSVnv(init_thresh_)));
	sv_setsv(sv_min_thresh,  sv_2mortal(newSVnv(min_thresh_ )));
	sv_setsv(sv_max_thresh,  sv_2mortal(newSVnv(max_thresh_ )));
}

void XsSurfAdjuster::detectImpl(const Mat& image, vector<KeyPoint>& keypoints, const cv::Mat& mask) const
{
    Ptr<FeatureDetector> surf = FeatureDetector::create("SURF");
    surf->set("hessianThreshold", thresh_);
    surf->detect(image, keypoints, mask);
}

void XsSurfAdjuster::tooFew(int minv, int n_detected)
{
	dSP;
	ENTER;
	SAVETMPS;
	PUSHMARK(SP);
	XPUSHs(sv_2mortal(newSViv(minv)));
	XPUSHs(sv_2mortal(newSViv(n_detected)));
	PUTBACK;
	call_pv((CLASS_ + "::tooFew").c_str(), 0);
	FREETMPS;
	LEAVE;
	thresh_ = SvNV(sv_thresh);
}

void XsSurfAdjuster::tooMany(int maxv, int n_detected)
{
	dSP;
	ENTER;
	SAVETMPS;
	PUSHMARK(SP);
	XPUSHs(sv_2mortal(newSViv(maxv)));
	XPUSHs(sv_2mortal(newSViv(n_detected)));
	PUTBACK;
	call_pv((CLASS_ + "::tooMany").c_str(), 0);
	FREETMPS;
	LEAVE;
	thresh_ = SvNV(sv_thresh);
}

bool XsSurfAdjuster::good() const
{
	dSP;
	ENTER;
	SAVETMPS;
	PUSHMARK(SP);
	// PUTBACK;
	int result = call_pv((CLASS_ + "::good").c_str(), 0);
	FREETMPS;
	LEAVE;
	return result;
}

Ptr<AdjusterAdapter> XsSurfAdjuster::clone() const
{
    Ptr<AdjusterAdapter> cloned_obj = new XsSurfAdjuster(
		CLASS_, init_thresh_, min_thresh_, max_thresh_);
    return cloned_obj;
}

#define FIX_CLASS(sv) \
	if (SvROK(sv)) { \
		char *p = strchr(CLASS, '='); \
		if (p) *p = '\0'; \
	} else

#define CHECK_DESTROY(sv) \
	if (SvREFCNT(sv) > 1) { \
		/* const char* CLASS = (const char*)sv_reftype(SvRV(sv), TRUE); \
		fprintf(stderr, "%s::DESTROY - ignored\n", CLASS); */ \
		XSRETURN_EMPTY; \
	} else

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
Feature2D::detectAndCompute(OUTLIST KeyPointV keypoints, OUTLIST CvMat* descriptors, CvArr* image, CvArr* mask = NULL)
CODE:
	Mat _descriptors;
	(*THIS)(cvarrToMat(image), mask? cvarrToMat(mask) : noArray(), keypoints, _descriptors);
	descriptors = matToCvmat(_descriptors);

KeyPointV
Feature2D::detect(CvArr* image, CvArr* mask = NULL)
CODE:
	THIS->detect(cvarrToMat(image), RETVAL, mask? cvarrToMat(mask) : Mat());
OUTPUT:
	RETVAL

CvMat*
Feature2D::compute(CvArr* image, KeyPointV keypoints)
CODE:
	Mat _descriptors;
	(*THIS)(cvarrToMat(image), noArray(), keypoints, _descriptors, true);
	RETVAL = matToCvmat(_descriptors);
OUTPUT:
	RETVAL

MODULE = Cv::Features2d		PACKAGE = Cv::Features2d::Feature2D::BRISK

BRISK*
BRISK::new(int thresh=30, int octaves=3, float patternScale=1.0)
INIT:
	FIX_CLASS(ST(0));
	if (sv_isobject(ST(0)) && (SvTYPE(SvRV(ST(0))) == SVt_PVMG)) {
		BRISK* THIS = (BRISK*)SvIV((SV*)SvRV(ST(0)));
		if (items < 2) thresh = THIS->get<int>("thres");
		if (items < 3) octaves = THIS->get<int>("octaves");
		// if (items < 4) patternScale = THIS->get<int>("patternScale");
	}

void
BRISK::DESTROY()


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
INIT:
	CHECK_DESTROY(ST(0));


MODULE = Cv::Features2d		PACKAGE = Cv::Features2d::FeatureDetector::GoodFeaturesToTrackDetector

GoodFeaturesToTrackDetector*
GoodFeaturesToTrackDetector::new(int maxCorners=1000, double qualityLevel=0.01, double minDistance=1, int blockSize=3, bool useHarrisDetector=false, double k=0.04)
INIT:
	FIX_CLASS(ST(0));
	if (sv_isobject(ST(0)) && (SvTYPE(SvRV(ST(0))) == SVt_PVMG)) {
		GoodFeaturesToTrackDetector* THIS = (GoodFeaturesToTrackDetector*)SvIV((SV*)SvRV(ST(0)));
		if (items < 2) maxCorners = THIS->get<int>("nfeatures");
		if (items < 3) qualityLevel = THIS->get<double>("qualityLevel");
		if (items < 4) minDistance = THIS->get<double>("minDistance");
		// if (items < 5) blockSize = THIS->get<int>("blockSize");
		if (items < 5) useHarrisDetector = THIS->get<bool>("useHarrisDetector");
		if (items < 6) k = THIS->get<double>("k");
	}

void
GoodFeaturesToTrackDetector::DESTROY()
INIT:
	CHECK_DESTROY(ST(0));


MODULE = Cv::Features2d		PACKAGE = Cv::Features2d::FeatureDetector::PyramidAdaptedFeatureDetector

PyramidAdaptedFeatureDetector*
PyramidAdaptedFeatureDetector::new(VOID* detector, int levels=2)
INIT:
	SvREFCNT_inc(ST(0));
C_ARGS: (FeatureDetector*)detector, levels

void
PyramidAdaptedFeatureDetector::DESTROY()
INIT:
	CHECK_DESTROY(ST(0));


MODULE = Cv::Features2d		PACKAGE = Cv::Features2d::FeatureDetector::DynamicAdaptedFeatureDetector

DynamicAdaptedFeatureDetector*
DynamicAdaptedFeatureDetector::new(VOID* adjuster, int min_features=400, int max_features=500, int max_iters=5)
C_ARGS: (AdjusterAdapter*)adjuster, min_features, max_features, max_iters
INIT:
	SvREFCNT_inc(ST(0));

void
DynamicAdaptedFeatureDetector::DESTROY()
INIT:
	CHECK_DESTROY(ST(0));


MODULE = Cv::Features2d		PACKAGE = Cv::Features2d::AdjusterAdapter

AdjusterAdapter*
create(const char* CLASS, const char* detectorType)
CODE:
	Ptr<AdjusterAdapter> THIS = FeatureDetector::create(detectorType);
	if (THIS.empty()) XSRETURN_UNDEF;
	RETVAL = THIS; THIS.addref();
OUTPUT:
	RETVAL

AdjusterAdapter*
AdjusterAdapter::clone()
INIT:
	const char* CLASS = (const char*)sv_reftype(SvRV(ST(0)), TRUE);
CODE:
	Ptr<AdjusterAdapter> CLONE = THIS->clone();
	if (CLONE.empty()) XSRETURN_UNDEF;
	RETVAL = CLONE; CLONE.addref();
OUTPUT:
	RETVAL

void
AdjusterAdapter::DESTROY()
INIT:
	CHECK_DESTROY(ST(0));


MODULE = Cv::Features2d		PACKAGE = Cv::Features2d::AdjusterAdapter::FastAdjuster

XsFastAdjuster*
XsFastAdjuster::new(int init_thresh = 20, bool nonmax = true, int min_thresh=1, int max_thresh=200)
C_ARGS:	(String)CLASS, init_thresh, nonmax, min_thresh, max_thresh

void
XsFastAdjuster::DESTROY()
INIT:
	CHECK_DESTROY(ST(0));


MODULE = Cv::Features2d		PACKAGE = Cv::Features2d::AdjusterAdapter::StarAdjuster

XsStarAdjuster*
XsStarAdjuster::new(int init_thresh = 20, bool nonmax = true)
C_ARGS:	(String)CLASS, init_thresh, nonmax

void
XsStarAdjuster::DESTROY()
INIT:
	CHECK_DESTROY(ST(0));


MODULE = Cv::Features2d		PACKAGE = Cv::Features2d::AdjusterAdapter::SurfAdjuster

XsSurfAdjuster*
XsSurfAdjuster::new(double initial_thresh=400.f, double min_thresh=2, double max_thresh=1000)
C_ARGS:	(String)CLASS, initial_thresh, min_thresh, max_thresh

void
XsSurfAdjuster::DESTROY()
INIT:
	CHECK_DESTROY(ST(0));


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
INIT:
	CHECK_DESTROY(ST(0));


MODULE = Cv::Features2d		PACKAGE = Cv::Features2d::DescriptorExtractor::OpponentColorDescriptorExtractor

OpponentColorDescriptorExtractor*
OpponentColorDescriptorExtractor::new(VOID* dextractor)
INIT:
	SvREFCNT_inc(ST(0));
C_ARGS: (DescriptorExtractor*)dextractor

void
OpponentColorDescriptorExtractor::DESTROY()
INIT:
	CHECK_DESTROY(ST(0));


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
