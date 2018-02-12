#!/usr/bin/env bats

load test_helper

. lib/gentoo

@test "gentoo base files available" {
    run sourceconfigs base gentoo
    [ -d "${GENTOO_FILES}" ]
}

# vim: set filetype=sh:
