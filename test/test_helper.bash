fixture() {
    FIXTURE_ROOT="$BATS_TEST_DIRNAME/fixtures/$1"
}

setup() {
    ORIGINAL_PWD=$PWD
    ORIGINAL_PATH=$PATH
    ORIGINAL_HOME=$HOME
    TEST_TMPDIR="$(mktemp -d)"
}

teardown() {
    cd $ORIGINAL_PWD
    rm -rf "${TEST_TMPDIR}"
    export PATH=$ORIGINAL_PATH
    export HOME=$ORIGINAL_HOME
    unset ARGPARSERS
    for key in $(env |grep -E "(GENTOO|VBOX|TEST)_" | cut -f1 -d=); do
        unset $key
    done
}
