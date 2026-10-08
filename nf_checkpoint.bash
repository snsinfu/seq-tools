#!/bin/bash
set -euo pipefail

run_name="${1:-last}"
archive="${2:-work-${run_name}.tar.zst}"
basedir="${PWD}"
compressor="zstd -T6"

tmp_list="$(mktemp)"
trap 'rm -f "${tmp_list}"' EXIT

echo "Collecting workdirs for '${run_name}'..."
nextflow log "${run_name}" -f status,workdir \
  | awk '$1 == "COMPLETED" || $1 == "CACHED" { print $2 }' \
  | sort -u \
  | grep -v '^-$' \
  | xargs -r realpath --relative-to "${basedir}" \
  > "${tmp_list}"

# Include .nextflow session database (required for -resume)
[ -d ".nextflow" ] && echo ".nextflow" >> "${tmp_list}"

echo "Archiving $(wc -l < "${tmp_list}") directories into '${archive}'..."
tar -I "${compressor}" -cf "${archive}" -T "${tmp_list}"

echo "Archive complete:"
du -h "${archive}"
