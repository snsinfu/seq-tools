#!/usr/bin/env Rscript

library(AnnotationHub)
library(GenomicRanges)
library(rtracklayer)

config_file <- "blacklist_config.tsv"

config <- read.delim(config_file, stringsAsFactors = FALSE)
ah <- AnnotationHub()

for (i in seq_len(nrow(config))) {
    genome <- config$genome[i]
    out_file <- config$output_file[i]
    raw_ids  <- config$ah_ids[i]

    ah_ids <- trimws(unlist(strsplit(raw_ids, "[,]+")))

    gr_list <- lapply(ah_ids, function(id) ah[[id]])
    gr_clean <- lapply(gr_list, granges)
    gr_unified <- reduce(do.call(c, gr_clean))

    export.bed(gr_unified, out_file)
    message(paste("Blacklist written to:", out_file, "\n"))
}
