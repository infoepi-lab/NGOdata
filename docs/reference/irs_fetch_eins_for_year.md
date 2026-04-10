# Fetch XML files for EINs for one index year (Range into TEOS ZIPs)

Fetch XML files for EINs for one index year (Range into TEOS ZIPs)

## Usage

``` r
irs_fetch_eins_for_year(
  year,
  eins,
  paths = irs_project_paths(),
  cache_env = NULL
)
```

## Arguments

- year:

  Tax year to fetch

- eins:

  Character vector of EINs to fetch

- paths:

  Named list of directory paths from
  [`irs_project_paths()`](https://infoepi-lab.github.io/irs-data/reference/irs_project_paths.md)

- cache_env:

  Environment for caching index data (optional)
