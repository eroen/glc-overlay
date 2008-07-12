# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils multilib toolchain-funcs

DESCRIPTION="Thread-safe ring buffer library"
HOMEPAGE="http://nullkey.ath.cx/packetstream/"
SRC_URI="http://nullkey.ath.cx/packetstream/archive/${P}.tar.gz"
RESTRICT="nomirror"

LICENSE="ZLIB"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="examples"

DEPEND=""
RDEPEND=""

EMULTILIB_PKG="true"

src_unpack() {
	unpack ${A}
}

src_compile_abi() {
	ABI=$1
	cd "${WORKDIR}/${PN}"

	emake \
		CC="$(tc-getCC)" \
		LD="$(tc-getCC)" \
		BUILD="build-${ABI}" \
		CFLAGS="$(get_abi_CFLAGS ${ABI})" \
		LDFLAGS="$(get_abi_LDFLAGS ${ABI})" \
		|| die "emake (${ABI}) failed"

	if use examples && $(is_final_abi ${ABI}) ; then
		emake examples \
			CC="$(tc-getCC)" \
			LD="$(tc-getCC)" \
			BUILD="build-${ABI}" \
			CFLAGS="$(get_abi_CFLAGS ${ABI})" \
			LDFLAGS="$(get_abi_LDFLAGS ${ABI})" \
			|| die "emake examples (${ABI}) failed"
	fi
}

src_compile() {
	for ABI in $(get_install_abis); do
		src_compile_abi ${ABI}
	done
}

src_install_abi() {
	ABI=$1
	cd "${WORKDIR}/${PN}"

	emake install \
		DESTDIR="${D}" \
		BUILD="build-${ABI}" \
		MLIBDIR="$(get_libdir ${ABI})" \
		|| die "emake install (${ABI}) failed"

	if use examples && $(is_final_abi ${ABI}) ; then
		emake install-examples \
			DESTDIR="${D}" \
			BUILD="build-${ABI}" \
			MLIBDIR="$(get_libdir ${ABI})" \
			|| die "emake install-examples (${ABI}) failed"
	fi
}

src_install() {
	for ABI in $(get_install_abis); do
		src_install_abi ${ABI}
	done
}
