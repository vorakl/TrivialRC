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
    output="$(RC_VERBOSE=true RC_WAIT_POLICY=wait_all ./trc -H 'exit 0' -D 'sleep 1; exit 2' -D 'sleep 2; exit 3' -F 'exit 0' -F 'exit 4' exit 5 |   sed -n 's|^.*(exitcode=\([[:digit:]]*\)):.*$|\1|p' | tr '\n' ' ')"
    test "${output}" = "0 4 5 2 3 0 "
}

it_catches_exitcodes_till_errs_in_sync() {
    set +e
    output="$(RC_VERBOSE=true RC_WAIT_POLICY=wait_err ./trc -D 'sleep 1; exit 2' -D 'sleep 2; exit 3' -F 'exit 0' -F 'exit 4' exit 5 |   sed -n 's|^.*(exitcode=\([[:digit:]]*\)):.*$|\1|p' | tr '\n' ' ')"
    test "${output}" = "0 4 143 143 "
}

it_rewrites_exitcode_on_halting_to_err() {
    set +e
    ./trc -H 'exit 11' exit 5
    test $? -eq 11
}

it_rewrites_exitcode_on_halting_to_ok() {
    set +e
    ./trc -H 'exit 0' exit 5
    test $? -eq 0
}

it_fails_on_booting_imm() {
    set +e
    ./trc -B 'exit 22' -H 'exit 0' exit 5
    test $? -eq 22
}

it_exits_143_on_async_any() {
    set +e
    output=$(RC_WAIT_POLICY=wait_any ./trc -D 'echo 11; exit 11' -D 'sleep 1; echo 22; exit 22')
    test $? -eq 143
    test "${output}" = "11"
}

it_exits_last_status_on_sync_any() {
    set +e
    output=$(RC_WAIT_POLICY=wait_any ./trc -F 'echo 11; exit 11' -F 'echo 22; exit 22')
    test $? -eq 11
    test "${output}" = "11"
}

it_exits_last_syncstatus_on_mix_any() {
    set +e
    output=$(RC_WAIT_POLICY=wait_any ./trc -D 'exit 33' -F 'echo 11; exit 11' -F 'echo 22; exit 22')
    test $? -eq 11
    test "${output}" = "11"
}

