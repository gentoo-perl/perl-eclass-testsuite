# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit perl-functions tester

DESCRIPTION="Test for perl_domodule"
HOMEPAGE="https://github.com/gentoo-perl/perl-eclass-testsuite"
SRC_URI=""

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-lang/perl"
RDEPEND="${DEPEND}"


do_test() {
	local phase
	phase="$1"
	[[ -e "${FILESDIR}/Gentoo-Eclass-Test-Perl-DoModule.pm" ]] || die "No files in this context"
	einfo "${FILESDIR}/Gentoo-Eclass-Test-Perl-DoModule.pm"

	[[ -d "${D}" ]] || die "No \${D} in this context"
	einfo "${D}"

	do_region "Argument parsing" # ---
	silent_deathless perl_domodule -unknown
	is_not_ok $? "unknown hyphen args die"

	silent_deathless perl_domodule -C
	is_not_ok $? "C without argument dies"

	do_region "Installation" # ---

	silent_deathless perl_domodule "${S}/${phase}/Gentoo/Eclass/Test/Perl/DoModule-${phase}.pm"
	is_ok $? "Installing a .pm file works"
	[[ -f "${ED}/$(perl_get_vendorlib)/DoModule-${phase}.pm" ]]
	is_ok $? "Installed .pm file is in \$ED"

	perl_domodule -C "${phase}/prefixed" "${S}/${phase}/Gentoo/Eclass/Test/Perl/DoModule-${phase}.pm"
	is_ok $? "Installing a .pm file with a prefix works"
	[[ -f "${ED}/$(perl_get_vendorlib)/${phase}/prefixed/DoModule-${phase}.pm" ]]
	is_ok $? "Installed .pm file is in \$ED"

	silent_deathless perl_domodule -r "${S}/${phase}/Gentoo/Eclass/Test/"
	is_ok $? "Installing a directory recursivley works"
	[[ -f "${ED}/$(perl_get_vendorlib)/Test/Perl/DoModule-${phase}.pm" ]]
	is_ok $? "Installed .pm file is in \$ED"

	perl_domodule -r -C "${phase}/recursive" "${S}/${phase}/Gentoo/Eclass/Test/Perl"
	is_ok $? "Installing a .pm file recursively with a prefix works"
	[[ -f "${ED}/$(perl_get_vendorlib)/${phase}/recursive/Perl/DoModule-${phase}.pm" ]]
	is_ok $? "Installed .pm file is in \$ED"

	do_final_status
}
perl_has_file_in_inc() {
	debug-print-function $FUNCNAME "$@"

	perl -we '
		for(@INC){
			next if ref $_;
			exit 0 if -r $_ . q[/] . $ARGV[0]
		}
		exit 1' "$@";
}

do_postinst_test() {
	local phase
	do_region "Checking loadable from perl"

	for phase in 'install' 'preinst'; do
		perl_has_file_in_inc "DoModule-${phase}.pm"
		is_ok $? "DoModule-${phase}.pm  in right place"

		perl_has_file_in_inc "${phase}/prefixed/DoModule-${phase}.pm"
		is_ok $? "${phase}/prefixed/DoModule-${phase}.pm  in right place"

		perl_has_file_in_inc "Test/Perl/DoModule-${phase}.pm"
		is_ok $? "Test/Perl/DoModule-${phase}.pm  in right place"

		perl_has_file_in_inc "${phase}/recursive/Perl/DoModule-${phase}.pm"
		is_ok $? "recursive/Perl/DoModule-${phase}.pm  in right place"

	done

	do_final_status
}

src_unpack() {
	# No ${D} in unpack
	# do_test
	local i
	mkdir -p "${S}" || die "Can't mkdir ${S}"

	for i in 'install' 'preinst'; do
		mkdir -p "${S}/${i}/Gentoo/Eclass/Test/Perl" || die "Can't mkdir ${S}/<stuff>/"
		cp "${FILESDIR}/Gentoo-Eclass-Test-Perl-DoModule.pm" \
			"${S}/${i}/Gentoo/Eclass/Test/Perl/DoModule-${i}.pm" || die "Can't copy"
	done
	touch "${S}/dummy-${P}" || die "Can't touch ${S}/dummy-${P}"
}
src_install() {
	do_test "install"
	dodoc "${S}/dummy-${P}"
}
pkg_preinst() {
	do_test "preinst"
}
pkg_postinst() {
	do_postinst_test
}
