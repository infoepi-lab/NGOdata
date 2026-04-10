# Full pipeline: fetch, parse, analyze, export

Full pipeline: fetch, parse, analyze, export

## Usage

``` r
run_irs990_pipeline(
  eins = character(),
  ein_file = NULL,
  years = 2017:2025,
  fetch = TRUE,
  parse = TRUE,
  analyze = TRUE,
  output_dir = NULL,
  full = FALSE,
  project_root = NULL,
  paths = NULL
)

run_irs990_pipeline_cli(argv = commandArgs(trailingOnly = TRUE))
```

## Arguments

- eins:

  Character vector of 9-digit EINs (no dashes required).

- ein_file:

  Optional path to text file (one EIN per line, `#` comments ok).

- years:

  Integer vector of IRS index years.

- fetch, parse, analyze:

  Logical toggles.

- output_dir:

  Override `paths$output_dir`.

- full:

  If TRUE, sets fetch, parse, analyze all TRUE.

- project_root:

  Repo root for
  [`irs_project_paths()`](https://infoepi-lab.github.io/irs-data/reference/irs_project_paths.md).

- paths:

  Optional pre-built paths list.

- argv:

  Character vector of command line arguments for CLI version
