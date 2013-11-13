# -*- mode: perl; coding: utf-8; tab-width: 4; -*-

use 5.008008;
use ExtUtils::MakeMaker;

our %PREREQ_PM = (
	'Cv' => '0.31',
	'Data::Structure::Util' => '0.15',
	'Test::LeakTrace'     => '0.140',
);

use Cv::Config;

my $cf = new Cv::Config;

WriteMakefile(
	NAME => "Cv::Features2d",
	VERSION_FROM => "lib/Cv/Features2d.pm",
	ABSTRACT_FROM => "lib/Cv/Features2d.pm",
	AUTHOR => 'MASUDA Yuta <yuta.cpan@gmail.com>',
	PREREQ_PM => \%PREREQ_PM,
	%Cv::Config::MM,
	INC => '-I.',
	XSOPT => '-C++ -hiertype',
	clean => {
		FILES => [ '*.tmp', '_Inline', 'cover_db', ]
	},
);

sub MY::postamble {
	"

cover:
	cover -delete
	-HARNESS_PERL_SWITCHES=-MDevel::Cover make test
	cover
	find cover_db -type d |xargs chmod +rx

";
}
