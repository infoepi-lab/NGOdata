# Package index

## Configuration & Setup

Project configuration and directory setup

- [`irs_project_paths()`](https://infoepi-lab.github.io/irs-data/reference/irs_project_paths.md)
  :

  Project paths (mirrors Python `config.py`)

- [`irs_ensure_dirs()`](https://infoepi-lab.github.io/irs-data/reference/irs_ensure_dirs.md)
  : Create default data directories if missing (exported so
  interactive/sourced workflows resolve the name).

## Data Acquisition

Core functions for fetching IRS data from bulk sources

- [`irs_download_index()`](https://infoepi-lab.github.io/irs-data/reference/irs_download_index.md)
  :

  Download IRS year index CSV (cached under `paths$index_dir`)

- [`irs_search_index()`](https://infoepi-lab.github.io/irs-data/reference/irs_search_index.md)
  : Search index rows for EINs in a year

- [`irs_fetch_eins_for_year()`](https://infoepi-lab.github.io/irs-data/reference/irs_fetch_eins_for_year.md)
  : Fetch XML files for EINs for one index year (Range into TEOS ZIPs)

- [`irs_smart_fetch()`](https://infoepi-lab.github.io/irs-data/reference/irs_smart_fetch.md)
  :

  Multi-year fetch (mirrors `IRSSmartDownloader.fetch_all`)

## XML Processing

Parse and extract data from Form 990 XML filings

- [`parse_990_xml()`](https://infoepi-lab.github.io/irs-data/reference/parse_990_xml.md)
  : Parse a 990 XML file into a filing list object

- [`peek_filing_ein()`](https://infoepi-lab.github.io/irs-data/reference/peek_filing_ein.md)
  : Peek EIN from early lines of a 990 XML file

- [`irs_xpaths_type_of_activities_conducted()`](https://infoepi-lab.github.io/irs-data/reference/irs_xpaths_type_of_activities_conducted.md)
  :

  XPath variants for Schedule F Part I "type of activities conducted"
  (same list as `FOREIGN_ACTIVITY_FIELDS$activities`).

- [`irs_read_schedule_f_part1_activities()`](https://infoepi-lab.github.io/irs-data/reference/irs_read_schedule_f_part1_activities.md)
  : Read "type of activities conducted" for each Schedule F Part I row
  in a 990 XML

## Board Analysis

Analyze board member information and governance structures

- [`board_members_to_tibble()`](https://infoepi-lab.github.io/irs-data/reference/board_members_to_tibble.md)
  : Convert board member list to tibble
- [`deduplicate_board_members()`](https://infoepi-lab.github.io/irs-data/reference/deduplicate_board_members.md)
  : Remove duplicate board member entries
- [`board_tenure_analysis()`](https://infoepi-lab.github.io/irs-data/reference/board_tenure_analysis.md)
  : Analyze board member tenure
- [`compensation_summary()`](https://infoepi-lab.github.io/irs-data/reference/compensation_summary.md)
  : Generate compensation summary statistics
- [`top_compensated()`](https://infoepi-lab.github.io/irs-data/reference/top_compensated.md)
  : Find top compensated board members
- [`role_distribution()`](https://infoepi-lab.github.io/irs-data/reference/role_distribution.md)
  : Analyze board member role distribution
- [`board_size_by_org()`](https://infoepi-lab.github.io/irs-data/reference/board_size_by_org.md)
  : Calculate board size metrics by organization
- [`cross_board_membership()`](https://infoepi-lab.github.io/irs-data/reference/cross_board_membership.md)
  : Identify individuals serving on multiple boards

## Grants Analysis

Process and analyze foreign grants and international activities

- [`foreign_activities_to_tibble()`](https://infoepi-lab.github.io/irs-data/reference/foreign_activities_to_tibble.md)
  : Convert foreign activities list to tibble
- [`foreign_individual_grants_to_tibble()`](https://infoepi-lab.github.io/irs-data/reference/foreign_individual_grants_to_tibble.md)
  : Convert foreign individual grants list to tibble
- [`foreign_grants_to_tibble()`](https://infoepi-lab.github.io/irs-data/reference/foreign_grants_to_tibble.md)
  : Convert foreign grants list to tibble
- [`grants_by_region()`](https://infoepi-lab.github.io/irs-data/reference/grants_by_region.md)
  : Summarize grants by geographic region
- [`grants_by_country()`](https://infoepi-lab.github.io/irs-data/reference/grants_by_country.md)
  : Summarize grants by recipient country
- [`grants_by_year()`](https://infoepi-lab.github.io/irs-data/reference/grants_by_year.md)
  : Summarize grants by tax year
- [`grants_by_ein_and_region()`](https://infoepi-lab.github.io/irs-data/reference/grants_by_ein_and_region.md)
  : Create EIN-by-region grant matrix
- [`grant_trends()`](https://infoepi-lab.github.io/irs-data/reference/grant_trends.md)
  : Analyze grant trends over time
- [`regional_heatmap_data()`](https://infoepi-lab.github.io/irs-data/reference/regional_heatmap_data.md)
  : Generate regional heatmap data
- [`top_recipients()`](https://infoepi-lab.github.io/irs-data/reference/top_recipients.md)
  : Find top grant recipients
- [`purpose_categories()`](https://infoepi-lab.github.io/irs-data/reference/purpose_categories.md)
  : Analyze grant purposes
- [`country_analysis()`](https://infoepi-lab.github.io/irs-data/reference/country_analysis.md)
  : Analyze grants by recipient country

## Export & Pipeline

Export processed data and run complete pipeline

- [`irs_export_csv()`](https://infoepi-lab.github.io/irs-data/reference/irs_export_csv.md)
  : Export data frame to CSV file

- [`irs_export_json()`](https://infoepi-lab.github.io/irs-data/reference/irs_export_json.md)
  : Export data frame to JSON file

- [`irs_export_filing_summary()`](https://infoepi-lab.github.io/irs-data/reference/irs_export_filing_summary.md)
  : Export filing summary report

- [`irs_export_full_analysis()`](https://infoepi-lab.github.io/irs-data/reference/irs_export_full_analysis.md)
  : Export comprehensive analysis to Excel workbook

- [`run_irs990_pipeline()`](https://infoepi-lab.github.io/irs-data/reference/run_irs990_pipeline.md)
  [`run_irs990_pipeline_cli()`](https://infoepi-lab.github.io/irs-data/reference/run_irs990_pipeline.md)
  : Full pipeline: fetch, parse, analyze, export

- [`parse_cli_args()`](https://infoepi-lab.github.io/irs-data/reference/parse_cli_args.md)
  :

  Parse CLI args (mirrors `scripts/run_analysis.py` options)
