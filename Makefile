# (c) Oleksii Tsvietnov, me@vorakl.name
#
# Variables:
ECHO_BIN ?= echo
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
	@${ECHO_BIN} "          make deploy"
	@${ECHO_BIN} "          make VERSION=1.4.0 deploy"
	@${ECHO_BIN} ""
	@${ECHO_BIN} "Description:"
	@${ECHO_BIN} "  setver         Set a new version (is taken from environment or file)."
	@${ECHO_BIN} "  settag         Set a new version as a tag to the last commit."
	@${ECHO_BIN} "  push           Push to the repo (with tags)."
	@${ECHO_BIN} "  deploy         Set a version, tag and push to the repo."
	@${ECHO_BIN} ""

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

deploy: setver settag push
