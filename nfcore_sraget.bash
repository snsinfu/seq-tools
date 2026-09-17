#!/bin/bash -eu

script_dir="$(dirname "$0")"
samplesheet="${1-samplesheet.csv}"

grep -o '[DES]RR[0-9]*' "${samplesheet}" | sort -u | xargs -L1 -P0 "${script_dir}/sra_get.bash"

for file in *.sra; do
    dockerx ncbi/sra-tools fasterq-dump -O. -pe$(nproc) "${file}"
done

pigz *.fastq
