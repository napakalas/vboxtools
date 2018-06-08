#!/usr/bin/env bats

load test_helper

. lib/gentoo

@test "gentoo base files available" {
    sourceconfigs base gentoo
    [ -d "${GENTOO_FILES}" ]
}

@test "download_gentoo_stage3 success" {
    fixture "download_gentoo"
    export PATH=$FIXTURE_ROOT:$PATH
    export GENTOO_MIRROR="http://example.com/gentoo"
    export TEST_release=stage3-amd64
    cd "${BATS_TMPDIR}"

    download_gentoo_release GENTOO_STAGE3 stage3-amd64
    [ "${GENTOO_STAGE3}" = "stage3-amd64-20180101T000000Z.iso" ]
    run cat stage3-amd64-20180101T000000Z.iso
    [ "$status" -eq 0 ]
    [ "${output}" = "http://example.com/gentoo/releases/amd64/autobuilds/20180101T000000Z/stage3-amd64-20180101T000000Z.iso" ]
}

@test "download_gentoo_stage3 failure" {
    fixture "download_gentoo"
    export PATH=$FIXTURE_ROOT:$PATH
    export GENTOO_MIRROR="http://example.com/gentoo"
    # the file didn't provide the expected release
    export TEST_release=hardened-amd64
    cd "${BATS_TMPDIR}"

    run download_gentoo_release GENTOO_STAGE3 stage3-amd64
    [ ! "${status}" -eq 0 ]
    [ -z "${GENTOO_STAGE3}" ]
}

# vim: set filetype=sh:
