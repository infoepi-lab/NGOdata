# Create EIN-by-region grant matrix

Generates a wide-format matrix showing grant amounts by organization
(EIN) and region, useful for comparative analysis.

## Usage

``` r
grants_by_ein_and_region(df)
```

## Arguments

- df:

  Data frame containing foreign grants data

## Value

Tibble with EINs as rows and regions as columns
