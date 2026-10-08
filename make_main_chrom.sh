#!/bin/sh -eu

dir="${1-.}"
genome_fai="${dir}/genome.fa.fai"
main_txt="${dir}/main.chrom.txt"
main_sizes="${dir}/main.chrom.sizes"
main_bed="${dir}/main.chrom.bed"

filter_fai() {
    awk '
        NR == FNR { # First file
            order[++n] = $1
            next
        }
        {
            fai[$1] = $0
        }
        END {
            for (i = 1; i <= n; i++) {
                if (order[i] in fai) {
                    print fai[order[i]]
                }
            }
        }' \
      "$1" "$2"
}

filter_fai "${main_txt}" "${genome_fai}" \
  | cut -f 1-2 \
  | tee "${main_sizes}" \
  | awk -v OFS='\t' '{ print $1, 0, $2 }' > "${main_bed}"
