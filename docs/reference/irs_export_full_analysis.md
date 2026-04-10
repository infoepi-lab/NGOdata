# Export comprehensive analysis to Excel workbook

Creates a multi-sheet Excel workbook with complete analysis results
including board member data, grants analysis, and summary statistics.

## Usage

``` r
irs_export_full_analysis(
  board_df,
  grants_df,
  activities_df = NULL,
  individual_grants_df = NULL,
  output_dir
)
```

## Arguments

- board_df:

  Data frame containing board member data

- grants_df:

  Data frame containing foreign grants data

- activities_df:

  Optional data frame containing foreign activities data

- individual_grants_df:

  Optional data frame containing individual grants data

- output_dir:

  Directory path for output file

## Value

Invisibly returns the full file path
