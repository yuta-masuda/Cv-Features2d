/* -*- mode: text; coding: utf-8; tab-width: 4 -*- */

#include "Cv.inc"

static AV* newAV_keypoints(vector<KeyPoint> &keypoints)
{
	AV* av_keypoints = newAV();
	int n = (int)keypoints.size();
	for (int i = 0; i < n; i++) {
		AV* av_kpt = newAV();
		AV* av_pt = newAV();
		av_push(av_pt, newSVnv(keypoints[i].pt.x));
		av_push(av_pt, newSVnv(keypoints[i].pt.y));
		av_push(av_kpt, newRV_inc(sv_2mortal((SV*)av_pt)));
		av_push(av_kpt, newSVnv(keypoints[i].size));
		av_push(av_kpt, newSVnv(keypoints[i].angle));
		av_push(av_kpt, newSVnv(keypoints[i].response));
		av_push(av_kpt, newSViv(keypoints[i].octave));
		av_push(av_kpt, newSViv(keypoints[i].class_id));
		av_push(av_keypoints, newRV_inc(sv_2mortal((SV*)av_kpt)));
	}
	return av_keypoints;
}


MODULE = Cv::Features2D::ORB		PACKAGE = Cv::Features2D::ORB

=xxx

ORB*
ORB::new(int nfeatures=500, float scaleFactor=1.2f, int nlevels=8, int edgeThreshold=31, int firstLevel=0, int WTA_K=2, int scoreType=ORB::HARRIS_SCORE, int patchSize=31)

=cut

ORB*
create(const char* CLASS, int nfeatures=500, float scaleFactor=1.2f, int nlevels=8, int edgeThreshold=31, int firstLevel=0, int WTA_K=2, int scoreType=ORB::HARRIS_SCORE, int patchSize=31)
CODE:
	RETVAL = new ORB(nfeatures, scaleFactor, nlevels, edgeThreshold, firstLevel, WTA_K, scoreType, patchSize);
OUTPUT:
	RETVAL

void
ORB::DESTROY()

void
ORB::detect(CvArr* image, CvArr* mask = NULL)
CODE:
	Mat _image = cv::cvarrToMat(image);
	vector<KeyPoint> _keypoints;
	I32 gimme = GIMME_V; /* wantarray */
	if (gimme == G_SCALAR) {
		if (mask) {
			Mat _mask = cvarrToMat(mask);
			(*THIS)(_image, _mask, _keypoints);
		} else {
			(*THIS)(_image, noArray(), _keypoints);
		}
		ST(0) = sv_newmortal();
		sv_setsv(ST(0), newRV((SV*)newAV_keypoints(_keypoints)));
		XSRETURN(1);
	} else if (gimme == G_ARRAY) {
		Mat _descriptors;
		if (mask) {
			Mat _mask = cvarrToMat(mask);
			(*THIS)(_image, _mask, _keypoints, _descriptors);
		} else {
			(*THIS)(_image, noArray(), _keypoints, _descriptors);
		}
		ST(0) = sv_newmortal();
		sv_setsv(ST(0), newRV((SV*)newAV_keypoints(_keypoints)));
		CvMat* descriptors = cvCreateMatHeader(
			_descriptors.rows, _descriptors.cols, _descriptors.flags);
		cvSetData(descriptors, _descriptors.data, CV_AUTOSTEP);
		ST(1) = sv_newmortal();
		sv_setref_pv(ST(1), "Cv::Mat", (void*)descriptors);
		XSRETURN(2);
	}
