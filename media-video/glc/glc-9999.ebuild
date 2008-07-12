# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils multilib toolchain-funcs git

DESCRIPTION="OpenGL & ALSA video capture tool"
HOMEPAGE="http://nullkey.ath.cx/projects/glc/"

GLC_REPO_URI="git://nullkey.ath.cx/~pyry/glc"
GLC_SUPPORT_REPO_URI="git://nullkey.ath.cx/~pyry/glc-support"

LICENSE="ZLIB"
SLOT="0"
KEYWORDS=""
IUSE="example-scripts"

DEPEND=">=dev-libs/packetstream-0.1.3
	>=dev-libs/elfhacks-0.4.0
	virtual/opengl
	x11-libs/libX11
	media-libs/alsa-lib
	dev-util/cmake"
RDEPEND=""

RESTRICT="nomirror"
EMULTILIB_PKG="true"

src_unpack() {
	EGIT_REPO_URI="${GLC_REPO_URI}" \
	EGIT_PROJECT="${PN}-git" \
		git_src_unpack

	EGIT_REPO_URI="${GLC_SUPPORT_REPO_URI}" \
	EGIT_PROJECT="${PN}-support-git" \
		git_src_unpack

	mkdir -p "${S}/support"
	mv  "${S}/minilzo" \
		"${S}/quicklz" \
		"${S}/lzjb" \
		"${S}/support/"
}

src_compile_abi() {
	local abi=$1
	local mybuilddir="${WORKDIR}/build-${abi}"

	mkdir "${mybuilddir}"
	cd "${mybuilddir}"

	local binaries="OFF"
	local headers="OFF"
	if $(is_final_abi ${abi}) ; then
		binaries="ON"
		headers="ON"
	fi

	local scripts="OFF"
	if use example-scripts && $(is_final_abi ${abi}) ; then
		scripts="ON"
	fi

	cmake "${S}" \
		-DCMAKE_INSTALL_PREFIX:PATH=/usr \
		-DCMAKE_BUILD_TYPE:STRING="Release" \
		-DCMAKE_CXX_COMPILER:FILEPATH="$(tc-getCXX)" \
		-DCMAKE_CXX_FLAGS_RELEASE:STRING="$(get_abi_var CXXFLAGS ${abi})" \
		-DCMAKE_C_COMPILER:FILEPATH="$(tc-getCC)" \
		-DCMAKE_C_FLAGS_RELEASE:STRING="$(get_abi_CFLAGS ${abi})" \
		-DMLIBDIR="$(get_libdir ${abi})" \
		-DBINARIES:BOOL="${binaries}" \
		-DSCRIPTS:BOOL="${scripts}" \
		-DHEADERS:BOOL="${headers}" \
		-DGIT_DIR:STRING="${EGIT_STORE_DIR}/${PN}-git" \
		|| die "cmake (${abi}) failed"
	emake || die "emake (${abi}) failed"
}

src_compile() {
	for ABI in $(get_install_abis); do
		src_compile_abi ${ABI}
	done
}

src_install_abi() {
	local abi=$1
	cd "${WORKDIR}/build-${abi}"
	emake DESTDIR="${D}" install \
		|| die "emake install (${abi}) failed"
}

src_install() {
	for ABI in $(get_install_abis); do
		src_install_abi ${ABI}
	done
}
