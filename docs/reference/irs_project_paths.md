# Project paths (mirrors Python `config.py`)

Project paths (mirrors Python `config.py`)

## Usage

``` r
irs_project_paths(project_root = NULL)
```

## Arguments

- project_root:

  Repository root. If `NULL`, uses env `IRS_DATA_ROOT`, else walks up
  from [`getwd()`](https://rdrr.io/r/base/getwd.html) for
  `pyproject.toml` + `config.py` (finds `irs-data` even when cwd is
  `R/infoepi.NGOdata`), else
  [`getwd()`](https://rdrr.io/r/base/getwd.html).

## Value

Named list of absolute paths.
