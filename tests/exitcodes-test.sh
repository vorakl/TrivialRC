#!/usr/bin/env roundup

describe "Checks exit codes"

before() {
    cd ..
}

after() {
    cd -
}

it_catches_all_exitcodes() {
    set +e
    output="$(RC_VERBOSE=true RC_WAIT_POLICY=wait_all ./trc -D 'sleep 1; exit 2' -D 'sleep 2; exit 3' -F 'exit 0' -F 'exit 4' exit 5 |   sed -n 's|^.*(exitcode=\([[:digit:]]*\)):.*$|\1|p' | tr '\n' ' ')"
    test "${output}" = "0 4 5 2 3 "
}

it_catches_exitcodes_till_errs() {
    set +e
    output="$(RC_VERBOSE=true RC_WAIT_POLICY=wait_err ./trc -D 'sleep 1; exit 2' -D 'sleep 2; exit 3' -F 'exit 0' -F 'exit 4' exit 5 |   sed -n 's|^.*(exitcode=\([[:digit:]]*\)):.*$|\1|p' | tr '\n' ' ')"
    test "${output}" = "0 4 143 143 "
}

