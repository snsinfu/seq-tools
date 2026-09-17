#!/bin/bash

for sra in "$@"; do
    case "${sra}" in
    [DES]RR*)
        aws s3 cp --no-sign-request "s3://sra-pub-run-odp/sra/${sra}/${sra}" "${sra}.sra"
        ;;
    *)  echo "unrecognized sra ID: ${sra}" >&2
        exit 1
    esac
done
