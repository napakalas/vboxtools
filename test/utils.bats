#!/usr/bin/env bats

load test_helper

. lib/utils

@test "reqstmt true" {
    demo () {
        reqstmt true
        echo "passed"
    }
    run demo
    [ "$output" = "passed" ]
}

@test "reqstmt false" {
    demo () {
        reqstmt false
        echo "passed"
    }
    run demo
    [ ! "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "checkenv not set" {
    FOO=foo
    unset BAR

    run checkenv BAR
    [ ! "$status" -eq 0 ]
    [ "$output" = "BAR is undefined" ]

    run checkenv FOO BAR
    [ ! "$status" -eq 0 ]
    [ "$output" = "BAR is undefined" ]
}

@test "checkenv set all" {
    FOO=foo
    BAR=bar
    result="$(checkenv FOO BAR)"
    [ -z "$result" ]
}

@test "checkenvfile not defined" {
    fixture "checkenvfile"
    cd $FIXTURE_ROOT
    run checkenvfile FOO
    [ ! "$status" -eq 0 ]
    [ "$output" = "FOO is undefined" ]
}

@test "checkenvfile not created" {
    fixture "checkenvfile"
    FOO=foo
    cd $FIXTURE_ROOT
    run checkenvfile FOO
    [ ! "$status" -eq 0 ]
    [ "$output" = "foo is missing in working directory; aborting" ]
}

@test "checkenvfile created" {
    fixture "checkenvfile"
    BAR=bar
    cd $FIXTURE_ROOT
    run checkenvfile BAR
    [ "$status" -eq 0 ]
    [ -z "$result" ]
}

@test "putscancode passthru" {
    run putscancode ""
    [ "$status" -eq 0 ]
    [ "$output" = "1c 9c" ]

    run putscancode "hello world"
    [ "$status" -eq 0 ]
    [ "$output" = "23 a3 12 92 26 a6 26 a6 18 98 39 b9 11 91 18 98 13 93 26 a6 20 a0 1c 9c" ]
}

@test "runscancode default" {
    fixture "keyboardputscancode"
    export PATH=$FIXTURE_ROOT:$PATH
    VBOX_NAME=box
    run runscancode ""
    [ "$status" -eq 0 ]
    [ "${output}" = 'VBoxManage controlvm "box" keyboardputscancode 1c 9c' ]

    VBOX_SCANCODE_LIMIT=3
    run runscancode "hello"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = 'VBoxManage controlvm "box" keyboardputscancode 23 a3 12' ]
    [ "${lines[1]}" = 'VBoxManage controlvm "box" keyboardputscancode 92 26 a6' ]

    VBOX_NAME="f o o"
    run runscancode ""
    [ "$status" -eq 0 ]
    [ "${output}" = 'VBoxManage controlvm "f o o" keyboardputscancode 1c 9c' ]
}

@test "runscancode all arguments" {
    fixture "keyboardputscancode"
    export PATH=$FIXTURE_ROOT:$PATH
    run runscancode "hello world" foo 2
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = 'VBoxManage controlvm "foo" keyboardputscancode 23 a3' ]
    [ "${lines[1]}" = 'VBoxManage controlvm "foo" keyboardputscancode 12 92' ]
}

@test "sourceconfigs base" {
    sourceconfigs base
    [ "$VBOX_DISK_SIZE" = "10000" ]
}

@test "sourceconfigs missing not found" {
    run sourceconfigs no_such_file
    [ ! "$status" -eq 0 ]
}

# vim: set filetype=sh:
