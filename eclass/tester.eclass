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

silent_deathless() {
	if [[ $# -lt 1 ]]; then
		die "$FUNCNAME(): Missing argument"
	fi
	# Subshell to catch "exit" calls
	(
		# isolated-functions.eclass calls "kill" to terminate
		# the root bash PID instead of simply killing the subshell
		# This is *not* what we want die() to mean, and we only
		# want die() to kill the subshell, otherwise we _cant_ test it
		#
		# Hence, we add a hook to call exit() long before kill gets called
		# by exploiting a die hook
		export EBUILD_DEATH_HOOKS="$EBUILD_DEATH_HOOKS break_die_boomerang"

		function break_die_boomerang() { exit 1; }

		# This prevents all logging from working
		function __elog_base() { return 0; }

		# eerror calls echo directly instead of __vecho
		function eerror() { return 0; }

		PORTAGE_QUIET=1 "$@"
	)
}
