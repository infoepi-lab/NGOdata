#' Export data frame to CSV file
#'
#' Exports a data frame to a CSV file in the specified output directory.
#'
#' @param df Data frame to export
#' @param filename Name of the output CSV file
#' @param output_dir Directory path for output file
#' @return Invisibly returns the full file path
#' @export
irs_export_csv <- function(df, filename, output_dir) {
  if (!nrow(df)) return(invisible(NULL))
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  readr::write_csv(df, file.path(output_dir, filename))
  invisible(file.path(output_dir, filename))
}

#' Export data frame to JSON file
#'
#' Exports a data frame to a pretty-formatted JSON file in the specified directory.
#'
#' @param df Data frame to export
#' @param filename Name of the output JSON file
#' @param output_dir Directory path for output file
#' @return Invisibly returns the full file path
#' @export
irs_export_json <- function(df, filename, output_dir) {
  if (!nrow(df)) return(invisible(NULL))
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  jsonlite::write_json(df, file.path(output_dir, filename), pretty = TRUE)
  invisible(file.path(output_dir, filename))
}

#' Export filing summary report
#'
#' Creates a summary CSV of parsed filings with key metadata.
#'
#' @param filings List of filing objects from XML parsing
#' @param output_dir Directory path for output file
#' @return Invisibly returns the full file path
#' @export
irs_export_filing_summary <- function(filings, output_dir) {
  if (!length(filings)) return(invisible(NULL))
  rows <- lapply(filings, filing_summary)
  df <- dplyr::bind_rows(rows)
  irs_export_csv(df, "filing_summaries.csv", output_dir)
}

#' Export comprehensive analysis to Excel workbook
#'
#' Creates a multi-sheet Excel workbook with complete analysis results
#' including board member data, grants analysis, and summary statistics.
#'
#' @param board_df Data frame containing board member data
#' @param grants_df Data frame containing foreign grants data
#' @param activities_df Optional data frame containing foreign activities data
#' @param individual_grants_df Optional data frame containing individual grants data
#' @param output_dir Directory path for output file
#' @return Invisibly returns the full file path
#' @export
irs_export_full_analysis <- function(
    board_df,
    grants_df,
    activities_df = NULL,
    individual_grants_df = NULL,
    output_dir
) {
  if (!requireNamespace("openxlsx", quietly = TRUE)) {
    message("Install optional package 'openxlsx' for Excel export.")
    return(invisible(NULL))
  }
  sheets <- list()
  if (nrow(board_df)) {
    sheets[["All Board Members"]] <- board_df
    sheets[["Top Compensated"]] <- top_compensated(board_df)
    sheets[["Board Size by Org"]] <- board_size_by_org(board_df)
    cb <- cross_board_membership(board_df)
    if (nrow(cb)) sheets[["Cross-Board Members"]] <- cb
  }
  if (nrow(grants_df)) {
    sheets[["All Foreign Grants"]] <- grants_df
    rh <- regional_heatmap_data(grants_df)
    if (nrow(rh)) sheets[["Grants by Region x Year"]] <- rh
    sheets[["Grant Trends"]] <- grant_trends(grants_df)
    sheets[["Top Recipients"]] <- top_recipients(grants_df)
    ca <- country_analysis(grants_df)
    if (nrow(ca)) sheets[["Grants by Country"]] <- ca
    pc <- purpose_categories(grants_df)
    if (nrow(pc)) sheets[["Grant Purposes"]] <- pc
  }
  if (!is.null(activities_df) && nrow(activities_df)) {
    sheets[["Foreign Activities"]] <- activities_df
  }
  if (!is.null(individual_grants_df) && nrow(individual_grants_df)) {
    sheets[["Individual Grants"]] <- individual_grants_df
  }
  if (!length(sheets)) return(invisible(NULL))
  path <- file.path(output_dir, "990_full_analysis.xlsx")
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  wb <- openxlsx::createWorkbook()
  for (nm in names(sheets)) {
    sn <- substr(nm, 1L, 31L)
    openxlsx::addWorksheet(wb, sn)
    openxlsx::writeData(wb, sn, sheets[[nm]])
  }
  openxlsx::saveWorkbook(wb, path, overwrite = TRUE)
  invisible(path)
}
