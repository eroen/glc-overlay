# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils multilib toolchain-funcs

DESCRIPTION="Various ELF run-time hacks"
HOMEPAGE="http://nullkey.ath.cx/elfhacks/"
SRC_URI="http://nullkey.ath.cx/elfhacks/archive/${P}.tar.gz"
RESTRICT="nomirror"

LICENSE="ZLIB"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=">=sys-libs/glibc-2.2.4"
RDEPEND=""

EMULTILIB_PKG="true"

src_unpack() {
	unpack ${A}
}

src_compile() {
	cd "${WORKDIR}/${PN}"
	
	for ABI in $(get_install_abis); do
		emake \
			CC="$(tc-getCC)" \
			LD="$(tc-getCC)" \
			BUILD="build-${ABI}" \
			CFLAGS="$(get_abi_CFLAGS ${ABI})" \
			LDFLAGS="$(get_abi_LDFLAGS ${ABI})" \
			|| die "emake (${ABI}) failed"
	done
}

src_install() {
	cd "${WORKDIR}/${PN}"
	
	for ABI in $(get_install_abis); do
		emake install \
			DESTDIR="${D}" \
			BUILD="build-${ABI}" \
			MLIBDIR="$(get_libdir ${ABI})" \
			|| die "emake install (${ABI}) failed"
	done
}
