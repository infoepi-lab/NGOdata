# Create default data directories if missing (exported so interactive/sourced workflows resolve the name).

Create default data directories if missing (exported so
interactive/sourced workflows resolve the name).

## Usage

``` r
irs_ensure_dirs(paths = irs_project_paths())
```

## Arguments

- paths:

  Named list of directory paths from
  [`irs_project_paths()`](https://infoepi-lab.github.io/irs-data/reference/irs_project_paths.md)
