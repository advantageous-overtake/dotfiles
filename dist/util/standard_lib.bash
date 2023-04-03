#!/usr/bin/env bash

executable_exists( ) {
    command -v "$1" | wc -l
}

relative_to( ) {
    realpath -L --relative-to="$1" "$2" -m
}

reduce_path( ) {
    realpath -L --relative-to="$1" "$2" -m
}

repository_root( ) {
    realpath -L "$( dirname "$( git rev-parse --git-dir 2> /dev/null )" )"
}

# explicit word-splitting
# shellcheck disable=2046
export -f $( grep -Eo "^[a-z_]+\(\s*\)\s*{$" "${BASH_SOURCE[0]}" | grep -Eo "^[a-z_]+" | tr "\n" " " )