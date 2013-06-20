# -*- mode: perl; coding: utf-8; tab-width: 4 -*-

use strict;
use warnings;
use Test::More qw(no_plan);
# use Test::More;
use Test::Exception;
BEGIN { use_ok('Cv') }
BEGIN { use_ok('Cv::Features2d', ':all') }

sub capture (&) {
	local $Cv::IndexParams::VERBOSE = 1;
	# local $; = ":";
	my $subr = shift;
	my $tmp = 'a.tmp';
	local *STDERR_COPY;
	open(STDERR_COPY, '>&STDERR');
	local *STDERR;
	open(STDERR, ">$tmp");
	&$subr;
	my %cap;
	for (`cat $tmp`) {
		# print STDERR_COPY $_;
		chop;
		/^([^=]*)=(.*)/;
		my ($var, $index) = split($;, $1);
		my ($name, $type, $str, $num) = split($;, $2);
		if ($type == 7) {
			$cap{$var}{"$name:a"} = $str;
		} elsif ($str =~ /^\w$/) {
			$cap{$var}{"$name:$str"} = $num + 0;
		} else {
			$cap{$var}{$name} = $num + 0; # algorithm
		}
	}
	unlink $tmp;
	%cap;
}

if (1) {
	my $ip = 'flann::KDTreeIndexParams';
	my $sp = 'flann::SearchParams';
	my %p = capture { FlannBasedMatcher() };
	# use Data::Dumper;
	# print STDERR Data::Dumper->Dump([\%p], [qw(*p)]);
	is($p{indexParams}{algorithm}, 1, "$ip.algorithm");
	is($p{indexParams}{'trees:i'}, 4, "$ip.trees");
	is($p{searchParams}{'checks:i'}, 32, "$sp.checks");
	is($p{searchParams}{'eps:f'}, 0, "$sp.eps");
	is($p{searchParams}{'sorted:b'}, 1, "$sp.sorted");
}

if (1) {
	my $ip = 'flann::IndexParams';
	my $sp = 'flann::SearchParams';
	my %indexParams = (
		algorithm => 6,
		table_number => 6,
		key_size => 12,
		multi_probe_level => 1,
		);
	my %searchParams = (
		checks => 32,
		eps => 0.0,
		'sorted:b' => 1,
		hw => 'hello, world',
		);
	my %p = capture { FlannBasedMatcher(\%indexParams, \%searchParams) };
	# use Data::Dumper;
	# print STDERR Data::Dumper->Dump([\%p], [qw(*p)]);
	is($p{indexParams}{algorithm}, 6, "$ip.algorithm");
	is($p{indexParams}{'table_number:i'}, 6, "$ip.table_number");
	is($p{indexParams}{'key_size:i'}, 12, "$ip.key_size");
	is($p{indexParams}{'multi_probe_level:i'}, 1, "$ip.multi_probe_level");
	is($p{searchParams}{'checks:i'}, 32, "$sp.checks");
	is($p{searchParams}{'eps:d'}, 0.0, "$sp.eps");
	is($p{searchParams}{'sorted:b'}, 1, "$sp.sorted");
	is($p{searchParams}{'hw:a'}, 'hello, world', "$sp.hw");
}

if (1) {
	my %indexParams = (
		algorithm => 6,
		'table_number:x' => 6,
		key_size => 12,
		multi_probe_level => 1,
		);
	throws_ok {
		FlannBasedMatcher(\%indexParams);
	} qr/can't use "x" to set indexParams/;
}

if (1) {
	my %indexParams = (
		algorithm => 6,
		table_number => 6,
		key_size => [1],
		multi_probe_level => 1,
		);
	throws_ok {
		my %p = FlannBasedMatcher(\%indexParams);
		use Data::Dumper;
		print STDERR Data::Dumper->Dump([\%p], [qw(*p)]);
	} qr/can't use ref-sv to set indexParams/;
}
