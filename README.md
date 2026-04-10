# infoepi.NGOdata


[![License:
MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![R](https://img.shields.io/badge/R-%3E%3D4.1.0-blue.svg)](https://r-project.org)

IRS Form 990 XML Pipeline (R Port) - R replication of the irs-data
Python pipeline for IRS bulk index/range fetch, Form 990 XML parsing
(Part VII, Schedule F), and analysis/export.

## Installation

### Quick Install

``` bash
git clone https://github.com/infoepi-lab/irs-data.git
cd irs-data/R/irs990
Rscript -e "install.packages('.', repos = NULL, type = 'source')"
```

Or from within R (no need to change directory):

``` r
install.packages("/path/to/irs-data/R/irs990", repos = NULL, type = "source")
```

> **Note:** The R package lives in the `R/irs990` subdirectory, **not** the repo root. If you get `invalid package` or `No such file or directory`, make sure you're in the `irs-data/R/irs990` folder (the one containing `DESCRIPTION`).

### Prerequisites by Operating System

| OS          | Requirements                            | Notes                 |
|------------------|----------------------------------|--------------------|
| **Windows** | R (\>= 4.1.0), Rtools                   | Uses `gcc` compiler   |
| **macOS**   | R (\>= 4.1.0), Xcode Command Line Tools | Uses `clang` compiler |
| **Linux**   | R (\>= 4.1.0), build-essential          | Uses `gcc` compiler   |

### Platform-Specific Setup

#### Windows

``` bash
git clone https://github.com/infoepi-lab/irs-data.git
cd irs-data\R\irs990
Rscript -e "install.packages('.', repos = NULL, type = 'source')"
```

On Windows, **do not** call `library(infoepi.NGOdata)` or
`devtools::load_all()` in the same session before reinstalling: the
loaded `infoepi.NGOdata.dll` cannot be overwritten, which produces
`Permission denied` and `cannot remove earlier installation`. **Restart
R** (fully quit the app if you use RStudio), open a **new** session,
install immediately without loading the package, then
`library(infoepi.NGOdata)`. If a failed install left
`00LOCK-infoepi.NGOdata` under your library folder
(`Sys.getenv("R_LIBS_USER")`), delete that folder while R is closed.

To create a **pak lockfile** in this package
(`pak::lockfile_create(..., lockfile = ".github/pkg.lock")`), your
working directory must be this folder (`R/irs990`) and the `.github`
directory must exist (it is included in the repository).

#### macOS

``` bash
# Install development tools (if needed)
xcode-select --install

git clone https://github.com/infoepi-lab/irs-data.git
cd irs-data/R/irs990
Rscript -e "install.packages('.', repos = NULL, type = 'source')"
```

#### Linux (Ubuntu/Debian)

``` bash
# Install development tools and libraries for compiled dependencies (xml2, httr2, zlib)
sudo apt-get update
sudo apt-get install -y build-essential r-base-dev zlib1g-dev libxml2-dev \
  libcurl4-openssl-dev libssl-dev

git clone https://github.com/infoepi-lab/irs-data.git
cd irs-data/R/irs990
Rscript -e "install.packages('.', repos = NULL, type = 'source')"
```

#### Linux (CentOS/RHEL/Fedora)

``` bash
# Install development tools (if needed)
sudo yum groupinstall "Development Tools"
# or for Fedora: sudo dnf groupinstall "Development Tools"

git clone https://github.com/infoepi-lab/irs-data.git
cd irs-data/R/irs990
Rscript -e "install.packages('.', repos = NULL, type = 'source')"
```

### Alternative: Install from R Console

For any platform, you can also install from within R. You can either set the working directory first, or pass the full path:

``` r
# Option 1: set working directory to the package folder, then install
setwd("/path/to/irs-data/R/irs990")
install.packages(".", repos = NULL, type = "source")

# Option 2: pass the full path directly (no need to change directory)
install.packages("/path/to/irs-data/R/irs990", repos = NULL, type = "source")
```

### Verify Installation

After installation on any platform:

``` r
library(infoepi.NGOdata)
```

## Features

-   **Data Acquisition**: Fetch IRS bulk data indexes and ranges
-   **XML Parsing**: Parse Form 990 XML files (Part VII, Schedule F)
-   **Board Analysis**: Analyze board member information
-   **Grants Analysis**: Analyze foreign grants data
-   **Export Tools**: Export processed data to various formats

## Dependencies

-   R (\>= 4.1.0)
-   dplyr, tidyr, httr2, jsonlite, readr, stringr, tibble, utils, xml2,
    openxlsx

## License

MIT
