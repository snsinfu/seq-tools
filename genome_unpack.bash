#!/bin/bash -eu

case $# in
0)  exit
    ;;
1)  :
    ;;
*)  printf "%s\0" "$@" | xargs -0 -P0 -L1 "$0"
    exit
esac

cd "$1"
echo "Unpacking $1 ..." >&2

for file in *.tar.zst; do
    tar xf "${file}"
done

for file in *.fa.zst *.gtf.zst; do
    unzstd "${file}"
done
