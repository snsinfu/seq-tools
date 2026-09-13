#!/bin/bash -eu

limit=
quiet=0

while getopts n:q opt; do
    case "${opt}" in
    n)  limit="${OPTARG}"
        ;;
    q)  quiet=1
        ;;
    *)  exit 1
    esac
done

shift $((OPTIND - 1))

dockerx ncbi/sra-tools vdb-dump -C READ_LEN "$1" \
  | awk -v limit="${limit}" -F : '
    /READ_LEN/ {
      count++
      if (limit != "" && count > limit) {
        exit
      }
      print $2
    }
    ' \
  | awk -v quiet="${quiet}" -F '[ ,]+' '
    {
      for (i = 1; i <= NF; i++) {
        if ($i > 0) { sum += $i; count++ }
      }
      if (!quiet && NR % 100000 == 0) {
        printf " %.1fM spots read\r", NR / 1e6 > "/dev/stderr"
      }
    }
    END {
      if (!quiet) {
        printf "\n" > "/dev/stderr"
      }
      print sum / count
    }'
