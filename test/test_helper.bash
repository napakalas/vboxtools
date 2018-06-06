fixture() {
    FIXTURE_ROOT="$BATS_TEST_DIRNAME/fixtures/$1"
}

setup() {
    ORIGINAL_PWD=$PWD
    ORIGINAL_PATH=$PATH
    ORIGINAL_HOME=$HOME
}

teardown() {
    cd $ORIGINAL_PWD
    export PATH=$ORIGINAL_PATH
    export HOME=$ORIGINAL_HOME
    unset ARGPARSERS
    for key in `env |grep VBOX_ | cut -f1 -d=`; do
        unset $key
    done
}
