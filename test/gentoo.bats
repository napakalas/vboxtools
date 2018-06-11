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

    _download_gentoo_release GENTOO_STAGE3 stage3-amd64
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

    run _download_gentoo_release GENTOO_STAGE3 stage3-amd64
    [ ! "${status}" -eq 0 ]
    # doesn't set the variable
    _download_gentoo_release GENTOO_STAGE3 stage3-amd64 || true
    [ -z "${GENTOO_STAGE3}" ]
}

@test "test download_gentoo_portage good" {
    fixture "download_gentoo"
    export PATH=$FIXTURE_ROOT:$PATH
    export GENTOO_MIRROR="http://example.com/gentoo"
    export GENTOO_PORTAGE_ID="portage"
    # the file didn't provide the expected release
    cd "${TEST_TMPDIR}"

    run download_gentoo_portage GENTOO_SNAPSHOT
    [ "${status}" -eq 0 ]
    # test will fail after 2999-12-31
    local value=${lines[0]}
    value=${lines#*URL:}
    value=${value%%-*}
    [ "${value}" = "http://example.com/gentoo/snapshots/portage" ]

    # since the dummy wget creates the exact file name, just check that
    # the intended effect is achieved.
    download_gentoo_portage GENTOO_SNAPSHOT
    run bash -c "ls ${TEST_TMPDIR}/${GENTOO_SNAPSHOT} | wc -l"
    [ "${output}" = '1' ]
    run bash -c "ls ${TEST_TMPDIR}/${GENTOO_SNAPSHOT}.gpgsig | wc -l"
    [ "${output}" = '1' ]
}

@test "test download_gentoo_portage fail" {
    fixture "download_gentoo"
    export PATH=$FIXTURE_ROOT:$PATH
    export GENTOO_MIRROR="http://example.com/gentoo"
    # ensure all fixture'd wget fails
    export TEST_retval=1
    cd "${TEST_TMPDIR}"
    run download_gentoo_portage GENTOO_SNAPSHOT
    [[ ${lines[4]} == *$(date +%Y%m%d --date='5 days ago')* ]]
    [[ ${lines[5]} = "failed to download gentoo snapshot" ]]
    [ ${#lines[@]} -eq 6 ]
}

@test "test _download_gentoo_release wrapped functions" {
    fixture "download_gentoo"
    export PATH=$FIXTURE_ROOT:$PATH

    cd "${TEST_TMPDIR}"

    export GENTOO_MIRROR="http://example.com/gentoo"

    export GENTOO_STAGE3_ID="stage3-x86"
    export TEST_release=$GENTOO_STAGE3_ID
    download_gentoo_stage3 GENTOO_STAGE3
    [ "${GENTOO_STAGE3}" = "stage3-x86-20180101T000000Z.iso" ]
    [ -f "${GENTOO_STAGE3}" ]

    export GENTOO_BOOT_ISO_ID="install-x86-full"
    export TEST_release=$GENTOO_BOOT_ISO_ID
    download_gentoo_boot_iso GENTOO_BOOT_ISO
    [ -f "${GENTOO_BOOT_ISO}" ]
}

@test "test locate_gentoo_part downloaded" {
    fixture "download_gentoo"
    export PATH=$FIXTURE_ROOT:$PATH

    cd "${TEST_TMPDIR}"
    # environment
    export GENTOO_MIRROR="http://example.com/gentoo"
    export GENTOO_BOOT_ISO_ID="arm-installer"
    # define the download id for the underlying download release function
    # also for the mocked identifier
    export TEST_release=$GENTOO_BOOT_ISO_ID

    # flag the stage3 part as a download
    export GENTOO_DOWNLOAD_BOOT_ISO=1
    locate_gentoo_part boot_iso .iso
    [ "${GENTOO_BOOT_ISO}" = "arm-installer-20180101T000000Z.iso" ]
    [ -f "${GENTOO_BOOT_ISO}" ]

    # ensure the info line is logged
    export VBOX_DEBUG=1
    # alternative iso, and stub the release as appropriate
    export GENTOO_BOOT_ISO_ID="x86-installer"
    export TEST_release=$GENTOO_BOOT_ISO_ID
    run locate_gentoo_part boot_iso .iso
    [ -f "x86-installer-20180101T000000Z.iso" ]
    [ "${lines[-1]}" = 'GENTOO_BOOT_ISO set as "x86-installer-20180101T000000Z.iso"' ]
}

@test "test locate_gentoo_part locate" {
    fixture "download_gentoo"
    export PATH=$FIXTURE_ROOT:$PATH

    cd "${TEST_TMPDIR}"

    # environment
    export GENTOO_MIRROR="http://example.com/gentoo"
    export GENTOO_STAGE3_ID="stage3-arm"
    # also for the mocked identifier
    export TEST_release=$GENTOO_STAGE3_ID

    # not created yet
    run locate_gentoo_part stage3 .tar.gz
    [ "${status}" -ne 0 ]
    [ "${lines[-1]}" = 'failed to locate GENTOO_STAGE3, defined as "stage3-arm*.tar.gz"' ]

    # now create a couple demo files
    touch stage3-arm-20180101.tar.gz
    touch stage3-arm-20180102.tar.gz

    # ensure the info line is logged
    export VBOX_DEBUG=1
    run locate_gentoo_part stage3 .tar.gz
    [ "${status}" -eq 0 ]
    [ "${lines[-1]}" = 'GENTOO_STAGE3 set as "stage3-arm-20180102.tar.gz"' ]

    # make another one and check that the setting happened
    touch stage3-arm-20180103.tar.gz
    touch stage3-arm-20180104.tar.xz

    locate_gentoo_part stage3 .tar.gz
    [ "${GENTOO_STAGE3}" = "stage3-arm-20180103.tar.gz" ]
}

@test "test locate_gentoo_part locate portage snapshot" {
    fixture "download_gentoo"
    export PATH=$FIXTURE_ROOT:$PATH

    cd "${TEST_TMPDIR}"
    export GENTOO_PORTAGE_ID="portage"
    export GENTOO_DOWNLOAD_PORTAGE=1
    locate_gentoo_part portage .tar.xz
    [ "${GENTOO_PORTAGE}" = "portage-$(date +%Y%m%d --date='1 day ago').tar.xz" ]
    downloaded=$GENTOO_PORTAGE

    unset GENTOO_DOWNLOAD_PORTAGE
    unset GENTOO_PORTAGE
    # try locating the freshly downloaded file
    locate_gentoo_part portage .tar.xz
    [ "${GENTOO_PORTAGE}" = "${downloaded}" ]

}

@test "test locate_gentoo_part undefined id" {
    fixture "download_gentoo"
    export PATH=$FIXTURE_ROOT:$PATH

    cd "${TEST_TMPDIR}"
    run locate_gentoo_part portage .tar.xz
    [ "${output}" = "GENTOO_PORTAGE_ID is not defined" ]
}

@test "test locate_gentoo_archives" {
    fixture "download_gentoo"
    export PATH=$FIXTURE_ROOT:$PATH
    cd "${TEST_TMPDIR}"

    export GENTOO_PORTAGE_ID="portage"
    export GENTOO_STAGE3_ID="stage3-amd64"
    export GENTOO_BOOT_ISO_ID="install-amd64-full"

    # a simple test for locating existing artifacts on filesystem.
    touch "portage-20180101.tar.xz"
    touch "stage3-amd64-20180101.tar.xz"
    touch "install-amd64-full-20180101.iso"

    locate_gentoo_archives

    [ "${GENTOO_PORTAGE}" = "portage-20180101.tar.xz" ]
    [ "${GENTOO_STAGE3}" = "stage3-amd64-20180101.tar.xz" ]
    [ "${GENTOO_BOOT_ISO}" = "install-amd64-full-20180101.iso" ]
}

# vim: set filetype=sh:
