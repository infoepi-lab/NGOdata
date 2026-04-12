# infoepi.NGOdata

[![R-CMD-check](https://github.com/infoepi-lab/NGOdata/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/infoepi-lab/NGOdata/actions/workflows/R-CMD-check.yaml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![R](https://img.shields.io/badge/R-%3E%3D4.1.0-blue.svg)](https://r-project.org)

R package for processing IRS Form 990 XML filings. Fetches bulk data from
the IRS, parses board member rosters (Part VII) and foreign grants/activities
(Schedule F), and exports structured datasets for analysis.

## Privacy notice

This package processes **public** IRS Form 990 data. It does **not** ship
any organization-specific data, EINs, or entity names. Users supply their
own EIN lists at runtime. Do not commit files that contain real EINs or
organization names to this repository.

## Installation

```bash
git clone https://github.com/infoepi-lab/NGOdata.git
cd NGOdata
Rscript -e "install.packages('.', repos = NULL, type = 'source')"
```

Or from within R:

```r
install.packages("/path/to/NGOdata", repos = NULL, type = "source")
```

### Prerequisites

| OS          | Requirements                             |
|-------------|------------------------------------------|
| **Windows** | R (>= 4.1.0), Rtools                    |
| **macOS**   | R (>= 4.1.0), Xcode Command Line Tools  |
| **Linux**   | R (>= 4.1.0), build-essential, zlib1g-dev, libxml2-dev, libcurl4-openssl-dev, libssl-dev |

### Verify installation

```r
library(infoepi.NGOdata)
```

## Quick start

### 1. Set up project paths

```r
library(infoepi.NGOdata)

paths <- irs_project_paths()
irs_ensure_dirs(paths)
```

### 2. Run the full pipeline

Create a plain-text file with one EIN per line (comments with `#` are ok):

```
# eins.txt
123456789
987654321
```

Then run:

```r
run_irs990_pipeline(
  ein_file = "eins.txt",
  years    = 2020:2024,
  full     = TRUE
)
```

Or from the command line:

```bash
Rscript exec/run_pipeline_cli.R --file eins.txt --years 2020-2024 --full
```

### 3. Use individual steps

```r
# Parse a single XML file
filing <- parse_990_xml("path/to/990.xml")

# Convert to tibbles
board_df  <- board_members_to_tibble(filing$board_members)
grants_df <- foreign_grants_to_tibble(filing$foreign_grants)

# Analyze
compensation_summary(board_df)
grants_by_region(grants_df)

# Export
irs_export_csv(board_df, "board_members.csv", paths$output_dir)
```

## Pipeline steps

| Step | Function | Description |
|------|----------|-------------|
| **Fetch** | `irs_smart_fetch()` | Downloads IRS index CSVs, looks up EINs, fetches XML filings |
| **Parse** | `parse_990_xml()` | Extracts board members, foreign grants, activities from XML |
| **Analyze** | `board_members_to_tibble()`, `grants_by_region()`, etc. | Converts to tibbles, deduplicates, summarizes |
| **Export** | `irs_export_csv()`, `irs_export_json()` | Writes CSV/JSON to output directory |

## Key functions

- `run_irs990_pipeline()` -- end-to-end orchestrator
- `parse_990_xml()` -- parse a single 990 XML file
- `board_members_to_tibble()` / `foreign_grants_to_tibble()` -- structured tibbles
- `deduplicate_board_members()` -- cross-filing deduplication
- `grants_by_region()` / `grants_by_country()` -- geographic summaries
- `compensation_summary()` / `top_compensated()` -- compensation analysis
- `irs_export_csv()` / `irs_export_json()` -- file export

## Output files

When the pipeline completes, the output directory contains:

| File | Contents |
|------|----------|
| `filing_summaries.csv` | One row per filing (EIN, tax year, revenue, etc.) |
| `board_members.csv` | All board member records |
| `board_members_deduped.csv` | Deduplicated board members |
| `foreign_grants.csv` | Schedule F foreign grants |
| `foreign_activities.csv` | Schedule F Part I activities |
| `foreign_individual_grants.csv` | Individual foreign grants |

## Dependencies

dplyr, tidyr, httr2, jsonlite, readr, stringr, tibble, xml2, openxlsx (suggested)

## License

MIT
