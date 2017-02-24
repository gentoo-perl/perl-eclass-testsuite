# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit perl-functions tester

DESCRIPTION="Test for perl_has_module"
HOMEPAGE="https://github.com/gentoo-perl/perl-eclass-testsuite"
SRC_URI=""

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

do_test() {
	do_region "Argument Handling"
	silent_deathless perl_has_module
	is_not_ok $? "No arguments = die"

	# ---
	do_region "Expected Present Modules"

	silent_deathless perl_has_module "base"
	is_ok $? "base.pm found"

	silent_deathless perl_has_module "threads"
	is_ok $? "deathy module threads.pm found"

	# ---
	do_region "Expected Missing modules"
	silent_deathless perl_has_module "Human::KENTNL::Test::IDoNotExist"
	is_not_ok $? "bogus module Human::KENTNL::Test::IDoNotExist not found"

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
