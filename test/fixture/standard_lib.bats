#!/usr/bin/env bats

ls -lah

pwd

CURRENT_FILE="$( pwd -L )/${0}"
CURRENT_DIRECTORY=$( dirname "$CURRENT_FILE" )

echo $CURRENT_FILE $CURRENT_DIRECTORY

load "test/test_helper/bats-support/load.bash"
load "test/test_helper/bats-assert/load.bash"

load "dist/util/standard_lib.bash"

# executable_exists

@test "executable_exists: should tell whenever a determined shell invocable exists" {
    run executable_exists "init"

    assert_output "1"
}

@test "executable_exists: should tell whenever a determined shell invocable does not exist" {
    run executable_exists "nonexistant_${RANDOM}"

    assert_output "0"
}

# relative_to

@test "relative_to: should function normally" {
    run relative_to "$HOME" "${HOME}/inner_directory"

    assert_output "inner_directory"
}

# reduce_path

@test "reduce_path: should function normally" {
    run reduce_path "/" "/home/${USER}/../../usr/bin"

    assert_output "usr/bin"
}

# repository_root

@test "repository_root: should function normally" {
    run repository_root

    assert_output "$REPOSITORY_PATH"
}
