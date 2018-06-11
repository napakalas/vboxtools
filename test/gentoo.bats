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
    cd "${TEST_TMPDIR}"

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
    cd "${TEST_TMPDIR}"

    run download_gentoo_release GENTOO_STAGE3 stage3-amd64
    [ ! "${status}" -eq 0 ]
    # doesn't set the variable
    download_gentoo_release GENTOO_STAGE3 stage3-amd64 || true
    [ -z "${GENTOO_STAGE3}" ]
}

@test "test download_gentoo_portage_snapshot good" {
    fixture "download_gentoo"
    export PATH=$FIXTURE_ROOT:$PATH
    export GENTOO_MIRROR="http://example.com/gentoo"
    # the file didn't provide the expected release
    cd "${TEST_TMPDIR}"

    run download_gentoo_portage_snapshot GENTOO_SNAPSHOT
    [ "${status}" -eq 0 ]
    # test will fail after 2999-12-31
    local value=${lines[0]}
    value=${lines#*URL:}
    value=${value%%-*}
    [ "${value}" = "http://example.com/gentoo/snapshots/portage" ]

    # since the dummy wget creates the exact file name, just check that
    # the intended effect is achieved.
    download_gentoo_portage_snapshot GENTOO_SNAPSHOT
    run bash -c "ls ${TEST_TMPDIR}/${GENTOO_SNAPSHOT} | wc -l"
    [ "${output}" = '1' ]
    run bash -c "ls ${TEST_TMPDIR}/${GENTOO_SNAPSHOT}.gpgsig | wc -l"
    [ "${output}" = '1' ]
}

@test "test download_gentoo_portage_snapshot fail" {
    fixture "download_gentoo"
    export PATH=$FIXTURE_ROOT:$PATH
    export GENTOO_MIRROR="http://example.com/gentoo"
    # ensure all fixture'd wget fails
    export TEST_retval=1
    cd "${TEST_TMPDIR}"
    run download_gentoo_portage_snapshot GENTOO_SNAPSHOT
    [[ ${lines[4]} == *$(date +%Y%m%d --date='5 days ago')* ]]
    [[ ${lines[5]} = "failed to download gentoo snapshot" ]]
    [ ${#lines[@]} -eq 6 ]
}

# vim: set filetype=sh:
