#!/bin/bash -eu

bucket="${S3_BUCKET_NAME:-}"

while getopts b: opt; do
    case "${opt}" in
    b)  bucket="${OPTARG}"
        ;;
    *)  exit 1
    esac
done

shift $((OPTIND - 1))

if [[ -z "${bucket}" ]]; then
    echo "Bucket name is not specified (-b name or S3_BUCKET_NAME env var)" >&2
    exit 1
fi

archive_rule=(
    -maxdepth 1
    \( -name '*.config' -o -name '*.csv' -o -name 'out*.tar.zst' \)
)

for prefix in "$@"; do
    find "${prefix}" "${archive_rule[@]}" \
      | awk -v bucket="${bucket}" '{ print "cp -u " $1 " s3://" bucket "/" $1 }' \
      | s5cmd run
done
