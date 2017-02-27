# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit perl-functions tester

DESCRIPTION="Test for perl_get_vendorlib"
HOMEPAGE="https://github.com/gentoo-perl/perl-eclass-testsuite"
SRC_URI=""

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-lang/perl"
RDEPEND="${DEPEND}"

perl_has_threads() {
	perl -MConfig -we '$Config{useithreads} ? exit 0 : exit 1'
}

diag_prefix() {
	einfo "EPREFIX: '${EPREFIX}'"
	einfo "EROOT: '${EROOT}'"
	einfo "ROOT: '${ROOT}'"
}

is_prefixed() {
	[[ ""         == "${EPREFIX}" ]] && return 1 # false
	[[ "${EROOT}" == "${EPREFIX}" ]] && return 1 # false
	return 0 # true
}

do_test() {
	local vendorpath
	diag_prefix

	is_prefixed || ewarn "This test best run under a working prefix build"

	vendorpath="$(perl_get_vendorlib)"
	is_ok $? "Calling perl_get_vendorlib succeeded"

	[[ -n "${vendorpath}" ]]
	is_ok $? "vendorpath is non-zero length (${vendorpath})"

	[[ -d "${EPREFIX}${vendorpath}" ]]
	is_ok $? "(eprefixed) vendorpath is a real directory";

	if is_prefixed; then
		# This is a hack because we can't afford for EPREFIX
		# or rawpath to have regex metacharacters in them
		# So we leverage the fact null characters are illegal in paths
		# to abuse them as an anchor for fixed-text matching.
		printf "\0%s" "${vendorpath}" | grep -aqFf <( printf "\0%s" "${EPREFIX}" )
		is_not_ok $? "raw vendor lib should not includes EPREFIX"
		
	fi
	[[ "${EPREFIX}${vendorpath}" == "$(perl_get_raw_vendorlib)" ]]
	is_ok $? "EPREFIX ( ${EPREFIX} ) + vendorpath (${vendorpath}) == rawpath $(perl_get_raw_vendorlib)"
	# ---
	do_final_status
}

pkg_pretend() {
	do_test
}
pkg_setup() {
	do_test
}
src_unpack() {
	do_test
	mkdir -p "${S}" || die "Can't mkdir ${S}"
	touch "${S}/dummy-${P}" || die "Can't touch ${S}/dummy-${P}"
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
	dodoc "${S}/dummy-${P}"
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
