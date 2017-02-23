#!/usr/bin/env roundup

describe "Checks if verbose options work"

before() {
    cd ..
}

after() {
    cd -
}

it_is_silent() {
   output="$(./trc)"
   test -z "${output}"
}

it_is_verbose() {
   verbose=$(RC_VERBOSE=true ./trc)
   verbose_extra=$(RC_VERBOSE=true RC_VERBOSE_EXTRA=true ./trc)
   test -n "${verbose}"
   test -n "${verbose_extra}"
   test $(echo "${verbose}" | wc -l) -ne $(echo "${verbose_extra}" | wc -l)
}
