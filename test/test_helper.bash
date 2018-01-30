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
    for key in `env |grep VBOX_ | cut -f1 -d=`; do
        unset $key
    done
}
