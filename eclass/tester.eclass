# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# @ECLASS: tester.eclass
# @MAINTAINER:
# Kent Fredric <kentnl@gentoo.org>
# @AUTHOR:
# Kent Fredric <kentnl@gentoo.org>
# @BLURB: A collection of eclass test methods
# @DESCRIPTION: Private eclasses used only for testing other eclasses

global_state=pass

do_pass() {
	einfo "pass: $@"
}
do_warn() {
	ewarn "weak fail: $@ ( in ${EBUILD_PHASE_FUNC} )"
	[[ ${global_state} == 'pass' ]] && global_state="weak fail"
}
do_fail() {
	eerror "fail: $@ ( in ${EBUILD_PHASE_FUNC} )"
	global_state="fail"
}
do_final_status() {
	if [[ "fail" == ${global_state} ]]; then
		die "<<FAIL in ${EBUILD_PHASE_FUNC}>>"
	fi
	if [[ "weak fail" == ${global_state} ]]; then
		ewarn "<<PASS: But possible issues in ${EBUILD_PHASE_FUNC}>>"
	else
		einfo "<<PASS>>"
	fi
}
is_ok() {
	local ok message
	ok=$1
	message=$2
	if [[ 0 == ${ok} ]]; then
		do_pass "${message}";
	else
		do_fail "${message}";
	fi
}
warn_ok() {
	local ok message
	ok=$1
	message=$2
	if [[ 0 == $ok ]]; then
		do_pass "${message}";
	else
		do_warn "${message}"
	fi
}
is_not_ok() {
	local ok message
	ok=$1
	message=$2
	if [[ 0 == ${ok} ]]; then
		do_fail "${message}";
	else
		do_pass "${message}";
	fi
}
warn_not_ok() {
	local ok message
	ok=$1
	message=$2
	if [[ 0 == $ok ]]; then
		do_warn "${message}";
	else
		do_pass "${message}"
	fi
}
do_region() {
	einfo "===[ $@ (${EBUILD_PHASE} @ ${EBUILD_PHASE_FUNC}) ]==="
}
