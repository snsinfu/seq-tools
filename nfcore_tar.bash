#!/bin/sh -eu

name="${1-out}"

tar -I zstd -cvf "${name}.tar.zst" \
  --exclude="${name}/genome/*.fa" \
  --exclude="*.bam*" \
  --exclude="*.bam.bai*" \
  --exclude="${name}/bwa/*/bigwig/*.bedGraph" \
  --exclude="${name}/*/fastqc/zips" \
  "${name}"
