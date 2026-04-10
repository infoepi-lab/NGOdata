#!/usr/bin/env Rscript
# Usage (after R CMD INSTALL . from the NGOdata repo root):
#   Rscript exec/run_pipeline_cli.R --eins 237404756 --full
# Or from anywhere with the package installed:
#   Rscript -e "infoepi.NGOdata::run_irs990_pipeline_cli()"

if (!requireNamespace("infoepi.NGOdata", quietly = TRUE)) {
  stop("Install the R package first: R CMD INSTALL .", call. = FALSE)
}
infoepi.NGOdata::run_irs990_pipeline_cli()
