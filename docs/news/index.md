# Changelog

## infoepi.NGOdata 0.1.0

### Initial Release

- Initial release of the IRS Form 990 data processing package
- Data acquisition functions for IRS bulk data downloads
- XML parsing capabilities for Form 990 filings (Part VII, Schedule F)
- Board member analysis and governance structure tools
- Foreign grants and international activities processing
- Export utilities for CSV, JSON formats
- Cross-platform support (Windows, macOS, Linux)

### Testing & Quality

- Comprehensive test suite with `testthat`
- Continuous integration with GitHub Actions
- Code coverage reporting with `codecov`
- Professional package structure following R standards

### Features

#### Data Acquisition

- [`irs_download_index()`](https://infoepi-lab.github.io/irs-data/reference/irs_download_index.md) -
  Download IRS bulk data indexes
- [`irs_fetch_eins_for_year()`](https://infoepi-lab.github.io/irs-data/reference/irs_fetch_eins_for_year.md) -
  Fetch EINs for specific years
- [`irs_smart_fetch()`](https://infoepi-lab.github.io/irs-data/reference/irs_smart_fetch.md) -
  Intelligent data fetching with caching

#### XML Processing

- [`parse_990_xml()`](https://infoepi-lab.github.io/irs-data/reference/parse_990_xml.md) -
  Main Form 990 XML parser
- [`peek_filing_ein()`](https://infoepi-lab.github.io/irs-data/reference/peek_filing_ein.md) -
  Quick EIN extraction from files
- Robust error handling and validation

#### Board Analysis

- [`board_members_to_tibble()`](https://infoepi-lab.github.io/irs-data/reference/board_members_to_tibble.md) -
  Convert board data to tidy format
- [`board_tenure_analysis()`](https://infoepi-lab.github.io/irs-data/reference/board_tenure_analysis.md) -
  Analyze board member tenure
- [`compensation_summary()`](https://infoepi-lab.github.io/irs-data/reference/compensation_summary.md) -
  Executive compensation analysis
- [`cross_board_membership()`](https://infoepi-lab.github.io/irs-data/reference/cross_board_membership.md) -
  Multi-organization board connections

#### Grants Analysis

- [`foreign_grants_to_tibble()`](https://infoepi-lab.github.io/irs-data/reference/foreign_grants_to_tibble.md) -
  Process foreign grant data
- [`grants_by_region()`](https://infoepi-lab.github.io/irs-data/reference/grants_by_region.md) -
  Regional grant distribution
- [`purpose_categories()`](https://infoepi-lab.github.io/irs-data/reference/purpose_categories.md) -
  Grant purpose classification

#### Export & Utilities

- [`irs_export_csv()`](https://infoepi-lab.github.io/irs-data/reference/irs_export_csv.md) -
  Export to CSV format
- [`irs_export_json()`](https://infoepi-lab.github.io/irs-data/reference/irs_export_json.md) -
  Export to JSON format
- [`irs_export_full_analysis()`](https://infoepi-lab.github.io/irs-data/reference/irs_export_full_analysis.md) -
  Complete analysis export
- [`run_irs990_pipeline()`](https://infoepi-lab.github.io/irs-data/reference/run_irs990_pipeline.md) -
  End-to-end pipeline execution
