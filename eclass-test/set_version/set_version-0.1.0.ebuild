# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit perl-functions

DESCRIPTION="Test for perl_set_version"
HOMEPAGE="https://github.com/gentoo-perl/perl-eclass-testsuite"
SRC_URI=""

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

global_state=pass

is_ok() {
	local ok message
	ok=$1
	message=$2
	if [[ 0 == ${ok} ]]; then
		einfo "pass: ${message}";
	else
		global_state=fail
		eerror "fail: ${message}";
	fi
}
warn_ok() {
	local ok message
	ok=$1
	message=$2
	if [[ 0 == $ok ]]; then
		einfo "pass: ${message}";
	else
		[[ "fail" != ${global_state} ]] && global_state="weak fail"
		ewarn "weak fail: ${message}";
	fi
}

do_test() {
	for varname in PERL_VERSION; do
		einfo "${varname} ${!varname}"
	done
	for varname in SITE_ARCH SITE_LIB; do
		[[ -e ${!varname} ]]
		warn_ok $? "-e \$${varname} ( ${!varname} )"
	done
	for varname in ARCH_LIB VENDOR_LIB VENDOR_ARCH; do
		[[ -e ${!varname} ]]
		is_ok $? "-e \$${varname} ( ${!varname} )"
	done

	if [[ "fail" == ${global_state} ]]; then 
		die "<<FAIL>>"
	fi
	if [[ "weak fail" == ${global_state} ]]; then
		ewarn "<<PASS: But possible issues>>"
	else
		einfo "<<PASS>>"
	fi
}

pkg_pretend() {
	perl_set_version || die "Failed to call set_version"
	do_test
}
pkg_setup() {
	perl_set_version || die "Failed to call set_version"
	do_test
}
src_unpack() {
	do_test
	mkdir -p "${S}" || die "Can't mkdir ${S}"
}
src_prepare() {
	do_test
	eapply_user
}
src_configure() {
	do_test
}
src_compile() {
	do_test
}
src_install() {
	do_test
}
pkg_preinst() {
	do_test
}
pkg_postinst() {
	do_test
}
pkg_prerm() {
	do_test
}
pkg_postrm() {
	do_test
}
pkg_config() {
	# Neat ... env is preserved here sometimes
	do_test
}
