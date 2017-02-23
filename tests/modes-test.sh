#!/usr/bin/env roundup

describe "Checks all available modes"

before() {
    cd ..
}

after() {
    cd -
}

it_boot() {
   set +e 
   ./trc -B 'e=11' -B 'exit $e'
   test $? -eq 11
}

it_async_any() {
    set +e
    output="$(./trc -D 'echo Hello' -D 'sleep 1; echo World')"
    test "${output}" = "Hello"
}

it_async_all() {
    output="$(RC_WAIT_POLICY=wait_all ./trc -D 'echo -n "Hello "' -D 'sleep 1; echo World')"
    test "${output}" = "Hello World"
}

it_sync_any() {
    set +e
    output="$(./trc -F 'echo Hello' echo World)"
    test "${output}" = "Hello"
}

it_sync_all() {
    output="$(RC_WAIT_POLICY=wait_all ./trc -B 'export wait_sec=1' -D 'sleep ${wait_sec}; echo Hello' -F 'echo -n "World "')"
    test "${output}" = "World Hello"
}

it_isolated() {
    output="$(RC_WAIT_POLICY=wait_all ./trc -B 'export v1=A' -D 'export v2=B' -F 'export v3=C' -F 'echo "${v1}${v2}${v3}"')"
    test "${output}" = "A"
}

