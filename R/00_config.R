irs_guess_project_root <- function() {
  start <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
  cur <- start
  for (i in 1:10) {
    if (file.exists(file.path(cur, "pyproject.toml")) &&
      file.exists(file.path(cur, "config.py"))) {
      return(cur)
    }
    nxt <- dirname(cur)
    if (identical(nxt, cur)) {
      break
    }
    cur <- nxt
  }
  start
}

#' Project paths (mirrors Python `config.py`)
#'
#' @param project_root Repository root. If `NULL`, uses env `IRS_DATA_ROOT`, else walks
#'   up from [getwd()] for `pyproject.toml` + `config.py` (finds `irs-data` even when cwd
#'   is `R/infoepi.NGOdata`), else [getwd()].
#' @return Named list of absolute paths.
#' @export
irs_project_paths <- function(project_root = NULL) {
  root <- project_root %||% Sys.getenv("IRS_DATA_ROOT", unset = NA_character_)
  if (is.na(root) || !nzchar(root)) {
    root <- irs_guess_project_root()
  }
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)

  # Check if we're in the R package directory
  r_pkg_dir <- file.path(root, "R", "irs990")
  if (!dir.exists(r_pkg_dir)) r_pkg_dir <- file.path(root, "R", "infoepi.NGOdata")
  if (dir.exists(r_pkg_dir)) {
    # Use inst/extdata for package data files
    extdata_dir <- file.path(r_pkg_dir, "inst", "extdata")
    data_dir <- file.path(root, "data")
    list(
      project_root = root,
      data_dir = data_dir,
      raw_xml_dir = file.path(data_dir, "raw", "xml"),
      raw_pdf_dir = file.path(data_dir, "raw", "pdf"),
      index_dir = file.path(extdata_dir, "index"),
      ocr_dir = file.path(data_dir, "ocr"),
      output_dir = file.path(data_dir, "output")
    )
  } else {
    # Original structure for Python compatibility
    data_dir <- file.path(root, "data")
    list(
      project_root = root,
      data_dir = data_dir,
      raw_xml_dir = file.path(data_dir, "raw", "xml"),
      raw_pdf_dir = file.path(data_dir, "raw", "pdf"),
      index_dir = file.path(data_dir, "index"),
      ocr_dir = file.path(data_dir, "ocr"),
      output_dir = file.path(data_dir, "output")
    )
  }
}

#' Create default data directories if missing (exported so interactive/sourced workflows resolve the name).
#' @param paths Named list of directory paths from `irs_project_paths()`
#' @export
irs_ensure_dirs <- function(paths = irs_project_paths()) {
  for (d in paths[c(
    "raw_xml_dir", "raw_pdf_dir", "index_dir", "ocr_dir", "output_dir"
  )]) {
    dir.create(d, recursive = TRUE, showWarnings = FALSE)
  }
  invisible(paths)
}

IRS_XML_BASE <- "https://apps.irs.gov/pub/epostcard/990/xml"
PROPUBLICA_API_BASE <- "https://projects.propublica.org/nonprofits/api/v2"

`%||%` <- function(x, y) {
  if (is.null(x) || (is.character(x) && length(x) == 1L && !nzchar(x))) y else x
}
