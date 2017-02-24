# (c) Oleksii Tsvietnov, me@vorakl.name
#
# Variables:
ECHO_BIN ?= echo
CP_BIN ?= cp
SED_BIN ?= sed
PWD_BIN ?= pwd
BASENAME_BIN ?= basename
GIT_BIN ?= git

# -------------------------------------------------------------------------
# Set a default target
.MAIN: usage

DIR = $(shell ${PWD_BIN} -P)
SELF = $(shell ${BASENAME_BIN} ${DIR})
VER = $(shell ${SED_BIN} -n '1s/^[[:space:]]*//; 1s/[[:space:]]*$$//; 1p' ${DIR}/version)
VERSION ?= ${VER}
LAST_COMMIT = $(shell ${GIT_BIN} log -1 | sed -n '/^commit/s/^commit //p')

usage:
	@${ECHO_BIN} "Usage: make [target] ..."
	@${ECHO_BIN} ""
	@${ECHO_BIN} "Examples: make setver"
	@${ECHO_BIN} "          make VERSION=1.15.2 setver"
	@${ECHO_BIN} "          make settag"
	@${ECHO_BIN} "          make push"
	@${ECHO_BIN} "          make release"
	@${ECHO_BIN} "          make VERSION=1.1.14 release"
	@${ECHO_BIN} ""
	@${ECHO_BIN} "Description:"
	@${ECHO_BIN} "  setver         Set a new version (is taken from environment or file)."
	@${ECHO_BIN} "  settag         Set a new version as a tag to the last commit."
	@${ECHO_BIN} "  push           Push to the repo (with tags)."
	@${ECHO_BIN} "  release        Set a version, tag and push to the repo."
	@${ECHO_BIN} "  test           Run all tests"
	@${ECHO_BIN} ""

test:
	@(cd tests && roundup)

setver:
	@${ECHO_BIN} "Setting version to ${VERSION}"
	@${SED_BIN} -i "s/# Version: .*$$/# Version: ${VERSION}/" ${DIR}/README.md
	@${SED_BIN} -i "s/# Version: .*$$/# Version: ${VERSION}/" ${DIR}/trc
	@${SED_BIN} -i "1s/.*/${VERSION}/" ${DIR}/version

settag:
	@${ECHO_BIN} "Setting ${VERSION} as a tag to ${LAST_COMMIT}"
	@${GIT_BIN} tag ${VERSION} ${LAST_COMMIT} 2>/dev/null || true

push:
	@${ECHO_BIN} "Pushing commits..."
	@${GIT_BIN} push origin
	@${ECHO_BIN} "Pushing tags..."
	@${GIT_BIN} push origin ${VERSION}

publish:
	@${CP_BIN} -f trc docs/

cirelease: test setver settag publish
	@${GIT_BIN} add .
	@${GIT_BIN} ci -m "Release new version: ${VERSION}"

release: cirelease push
