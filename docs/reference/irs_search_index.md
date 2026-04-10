# Search index rows for EINs in a year

Search index rows for EINs in a year

## Usage

``` r
irs_search_index(year, eins, paths = irs_project_paths(), cache_env = NULL)
```

## Arguments

- year:

  Tax year to search in

- eins:

  Character vector of EINs to search for

- paths:

  Named list of directory paths from
  [`irs_project_paths()`](https://infoepi-lab.github.io/irs-data/reference/irs_project_paths.md)

- cache_env:

  Environment for caching index data (optional)
