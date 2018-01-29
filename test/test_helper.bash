fixture() {
    FIXTURE_ROOT="$BATS_TEST_DIRNAME/fixtures/$1"
}

setup() {
    ORIGINAL_PWD=$PWD
    ORIGINAL_PATH=$PATH
}

teardown() {
    cd $ORIGINAL_PWD
    export PATH=$ORIGINAL_PATH
    # TODO bulk unset VBOX_*
    unset VBOX_NAME
}
