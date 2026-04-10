# Multi-year fetch (mirrors `IRSSmartDownloader.fetch_all`)

Multi-year fetch (mirrors `IRSSmartDownloader.fetch_all`)

## Usage

``` r
irs_smart_fetch(eins, years = 2017:2025, paths = irs_project_paths())
```

## Arguments

- eins:

  Character vector of EINs to fetch

- years:

  Integer vector of tax years to search (default: 2017:2025)

- paths:

  Named list of directory paths from
  [`irs_project_paths()`](https://infoepi-lab.github.io/irs-data/reference/irs_project_paths.md)
