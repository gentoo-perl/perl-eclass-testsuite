# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit perl-functions tester

DESCRIPTION="Test for perl_has_module_version"
HOMEPAGE="https://github.com/gentoo-perl/perl-eclass-testsuite"
SRC_URI=""

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

perl_has_threads() {
	perl -MConfig -we '$Config{useithreads} ? exit 0 : exit 1'
}
do_test() {
	do_region "Argument Handling"
	silent_deathless perl_has_module_version
	is_not_ok $? "No arguments = die"

	silent_deathless perl_has_module_version "base"
	is_not_ok $? "only 1 arguments = die"

	# ---
	do_region "Expected Present Modules"

	silent_deathless perl_has_module_version "base" 0
	is_ok $? "base.pm found"

	silent_deathless perl_has_module_version "base" '1.01'
	is_ok $? "base.pm >= 1.01 found"

	silent_deathless perl_has_module_version "base" '999999999'
	is_not_ok $? "base.pm >= 999999999 not expected found"

	if perl_has_threads; then
		# This fails because loading threads.pm
		silent_deathless perl_has_module_version "threads" 0
		is_ok $? "deathy module threads.pm found under thread-perl"
	else
		# This fails because loading threads.pm without threadperl
		# fails
		silent_deathless perl_has_module_version "threads" 0
		is_not_ok $? "deathy module not threads.pm found under no-thread-perl"
	fi

	# ---
	do_region "Expected Missing modules"
	silent_deathless perl_has_module_version "Human::KENTNL::Test::IDoNotExist" 0
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
