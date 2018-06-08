#!/usr/bin/env bats

load test_helper

@test "test download_gentoo fixture download" {
    fixture "download_gentoo"
    export PATH=$FIXTURE_ROOT:$PATH
    cd "${BATS_TMPDIR}"

    run wget -c -nv http://example.com/foobar.html
    [ "$output" = "2001-01-01 00:00:00 URL:http://example.com/foobar.html [101/101] -> \"foobar.html\" [1]" ]
    run cat foobar.html
    [ "$output" = "http://example.com/foobar.html" ]

    run wget -c -nv http://example.com/bar/baz/nothing.jpg
    [ "$output" = "2001-01-01 00:00:00 URL:http://example.com/bar/baz/nothing.jpg [101/101] -> \"nothing.jpg\" [1]" ]
    run cat nothing.jpg
    [ "$output" = "http://example.com/bar/baz/nothing.jpg" ]
}

@test "test download_gentoo fixture status" {
    fixture "download_gentoo"
    export PATH=$FIXTURE_ROOT:$PATH
    export TEST_release=demo
    cd "${BATS_TMPDIR}"
    run wget -q
    [ "${lines[0]}" = "# Latest as of Mon, 01 Jun 2018 00:00:00 +0000" ]
    [ "${lines[2]}" = '20180101T000000Z/demo-20180101T000000Z.iso 123456789' ]
}

# vim: set filetype=sh:
