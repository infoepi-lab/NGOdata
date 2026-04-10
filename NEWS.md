# infoepi.NGOdata 0.1.0

## Initial Release

* Initial release of the IRS Form 990 data processing package
* Data acquisition functions for IRS bulk data downloads
* XML parsing capabilities for Form 990 filings (Part VII, Schedule F)
* Board member analysis and governance structure tools
* Foreign grants and international activities processing
* Export utilities for CSV, JSON formats
* Cross-platform support (Windows, macOS, Linux)

## Testing & Quality

* Comprehensive test suite with `testthat`
* Continuous integration with GitHub Actions
* Code coverage reporting with `codecov`
* Professional package structure following R standards

## Features

### Data Acquisition
* `irs_download_index()` - Download IRS bulk data indexes
* `irs_fetch_eins_for_year()` - Fetch EINs for specific years
* `irs_smart_fetch()` - Intelligent data fetching with caching

### XML Processing
* `parse_990_xml()` - Main Form 990 XML parser
* `peek_filing_ein()` - Quick EIN extraction from files
* Robust error handling and validation

### Board Analysis
* `board_members_to_tibble()` - Convert board data to tidy format
* `board_tenure_analysis()` - Analyze board member tenure
* `compensation_summary()` - Executive compensation analysis
* `cross_board_membership()` - Multi-organization board connections

### Grants Analysis
* `foreign_grants_to_tibble()` - Process foreign grant data
* `grants_by_region()` - Regional grant distribution
* `purpose_categories()` - Grant purpose classification

### Export & Utilities
* `irs_export_csv()` - Export to CSV format
* `irs_export_json()` - Export to JSON format
* `irs_export_full_analysis()` - Complete analysis export
* `run_irs990_pipeline()` - End-to-end pipeline execution