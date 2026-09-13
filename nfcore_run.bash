#!/bin/bash -eu

usage() {
    cat << END
Usage: ${0##*/} [options] <pipeline[@revision]> [samplesheet.csv]

Options:
  -p <profile>   Nextflow profile (default: docker)
  -c <config>    Nextflow config file
  -w <dir>       Work directory (default: work)
  -o <dir>       Output directory (default: out)
  -x <option>    Extra Nextflow/pipeline option (repeatable)
END
}

profile="docker"
work_dir="work"
output_dir="out"
extra_options=()

while getopts p:c:w:o:x: opt; do
    case "${opt}" in
    p)  profile="${OPTARG}"
        ;;
    c)  nextflow_config="${OPTARG}"
        ;;
    w)  work_dir="${OPTARG}"
        ;;
    o)  output_dir="${OPTARG}"
        ;;
    x)  extra_options+=( "${OPTARG}" )
        ;;
    *)  usage >&2
        exit 1
    esac
done

shift $((OPTIND - 1))

case $# in
1)  pipeline_spec="$1"
    input_sheet="samplesheet.csv"
    ;;
2)  pipeline_spec="$1";
    input_sheet="$2"
    ;;
*)  usage >&2
    exit 1
esac

if [[ "${pipeline_spec}" == *"@"* ]]; then
    pipeline_name="${pipeline_spec%@*}"
    pipeline_version="${pipeline_spec##*@}"
else
    pipeline_name="${pipeline_spec}"
fi

# ----------------------------------------------------------------------------

mkdir -p "${output_dir}"

nextflow_options=(
    -profile  "${profile}"
    -work-dir "${work_dir}"
)

[[ -v pipeline_version ]] && nextflow_options+=( -revision "${pipeline_version}" )
[[ -v nextflow_config  ]] && nextflow_options+=( -config   "${nextflow_config}"  )

if [[ -d "${work_dir}" ]]; then
    nextflow_options+=( -resume )

    # Uncomment this if CALLPEAK does not rerun after parameter change.
    # grep -cR --include .command.run 'MACS[23]_CALLPEAK' "${work_dir}" \
    #   | awk -F: '$2 > 0 { print $1 }' \
    #   | xargs -r dirname \
    #   | xargs -r rm -rf
fi

pipeline_options=(
    --input  "${input_sheet}"
    --outdir "${output_dir}"
)

set -x
"${NEXTFLOW:-nextflow}" run "${pipeline_name}" \
  "${pipeline_options[@]}" \
  "${nextflow_options[@]}" \
  "${extra_options[@]}"
set +x

cat .nextflow.log >> "${output_dir}/nextflow.log"
