#!/usr/bin/env roundup

describe "Checks if it works with config files"

before() {
    cd ..
}

after() {
    cd -
}

it_prints_something() {
   output="$(RC_WAIT_POLICY=wait_all ./trc -w tests)"
   test "${output}" = "host: test-host; ip: 127.0.0.1. Good bye"
}
