# infoepi.NGOdata


[![License:
MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![R](https://img.shields.io/badge/R-%3E%3D4.1.0-blue.svg)](https://r-project.org)

IRS Form 990 XML Pipeline (R Port) - R replication of the irs-data
Python pipeline for IRS bulk index/range fetch, Form 990 XML parsing
(Part VII, Schedule F), and analysis/export.

## Installation

### Prerequisites by Operating System

| OS          | Requirements                            | Notes                 |
|-------------|-----------------------------------------|-----------------------|
| **Windows** | R (\>= 4.1.0), Rtools                   | Uses `gcc` compiler   |
| **macOS**   | R (\>= 4.1.0), Xcode Command Line Tools | Uses `clang` compiler |
| **Linux**   | R (\>= 4.1.0), build-essential          | Uses `gcc` compiler   |

### Platform-Specific Setup

#### Windows

``` bash
# Navigate to repository
cd C:\path\to\irs-data\R

# Install package
Rscript -e "install.packages('infoepi.NGOdata', repos = NULL, type = 'source')"
```

#### macOS

``` bash
# Install development tools (if needed)
xcode-select --install

# Navigate to repository
cd /path/to/irs-data/R

# Install package
Rscript -e "install.packages('infoepi.NGOdata', repos = NULL, type = 'source')"
```

#### Linux (Ubuntu/Debian)

``` bash
# Install development tools (if needed)
sudo apt-get update
sudo apt-get install build-essential r-base-dev

# Navigate to repository
cd /path/to/irs-data/R

# Install package
Rscript -e "install.packages('infoepi.NGOdata', repos = NULL, type = 'source')"
```

#### Linux (CentOS/RHEL/Fedora)

``` bash
# Install development tools (if needed)
sudo yum groupinstall "Development Tools"
# or for Fedora: sudo dnf groupinstall "Development Tools"

# Navigate to repository
cd /path/to/irs-data/R

# Install package
Rscript -e "install.packages('infoepi.NGOdata', repos = NULL, type = 'source')"
```

### Alternative: Install from R Console

For any platform, you can also install from within R:

``` r
# Navigate to the repository directory first, then start R
setwd("/path/to/irs-data/R")  # Use appropriate path format for your OS
install.packages('infoepi.NGOdata', repos = NULL, type = 'source')
```

### Verify Installation

After installation on any platform:

``` r
library(infoepi.NGOdata)
```

## Features

- **Data Acquisition**: Fetch IRS bulk data indexes and ranges
- **XML Parsing**: Parse Form 990 XML files (Part VII, Schedule F)
- **Board Analysis**: Analyze board member information
- **Grants Analysis**: Analyze foreign grants data
- **Export Tools**: Export processed data to various formats

## Dependencies

- R (\>= 4.1.0)
- dplyr, tidyr, httr2, jsonlite, readr, stringr, tibble, utils, xml2,
  openxlsx

## License

MIT
