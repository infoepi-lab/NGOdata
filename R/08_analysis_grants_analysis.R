#' Analyze grant trends over time
#'
#' Calculates annual statistics for grants including total amounts,
#' number of grants, and number of organizations.
#'
#' @param df Data frame containing foreign grants data
#' @return Tibble with grant trend analysis by year
#' @export
grant_trends <- function(df) {
  if (!nrow(df)) return(tibble::tibble())
  df |>
    dplyr::group_by(.data$tax_year) |>
    dplyr::summarise(
      total_cash = sum(.data$cash_amount, na.rm = TRUE),
      total_non_cash = sum(.data$non_cash_amount, na.rm = TRUE),
      total_amount = sum(.data$total_amount, na.rm = TRUE),
      num_grants = dplyr::n(),
      avg_grant_size = mean(.data$total_amount, na.rm = TRUE),
      num_orgs = dplyr::n_distinct(.data$ein),
      .groups = "drop"
    ) |>
    dplyr::arrange(.data$tax_year)
}

#' Generate regional heatmap data
#'
#' Creates a wide-format data frame suitable for heatmap visualization
#' showing grant amounts by region and year.
#'
#' @param df Data frame containing foreign grants data
#' @return Tibble with grant amounts by region (rows) and year (columns)
#' @export
regional_heatmap_data <- function(df) {
  if (!nrow(df)) return(tibble::tibble())
  df |>
    dplyr::group_by(.data$region, .data$tax_year) |>
    dplyr::summarise(total_amount = sum(.data$total_amount, na.rm = TRUE), .groups = "drop") |>
    tidyr::pivot_wider(
      id_cols = "region",
      names_from = "tax_year",
      values_from = "total_amount",
      values_fill = 0
    )
}

#' Find top grant recipients
#'
#' Identifies the organizations or individuals receiving the largest
#' total grant amounts across all years.
#'
#' @param df Data frame containing foreign grants data
#' @param n Number of top recipients to return (default 20)
#' @return Tibble with top grant recipients and their summary statistics
#' @export
top_recipients <- function(df, n = 20L) {
  if (!nrow(df)) return(tibble::tibble())
  rn <- as.character(df$recipient_name)
  df <- df[nzchar(rn) & !is.na(rn), , drop = FALSE]
  if (!nrow(df)) return(tibble::tibble())
  df |>
    dplyr::group_by(.data$recipient_name) |>
    dplyr::summarise(
      total_received = sum(.data$total_amount, na.rm = TRUE),
      grant_count = dplyr::n(),
      countries = paste(
        sort(unique(setdiff(as.character(.data$recipient_country), ""))),
        collapse = "; "
      ),
      regions = paste(sort(unique(as.character(.data$region))), collapse = "; "),
      donors = paste(sort(unique(as.character(.data$ein))), collapse = "; "),
      .groups = "drop"
    ) |>
    dplyr::slice_max(order_by = .data$total_received, n = n, with_ties = FALSE)
}

#' Analyze grant purposes
#'
#' Groups grants by purpose and calculates total amounts and counts
#' for each purpose category.
#'
#' @param df Data frame containing foreign grants data with purpose field
#' @return Tibble with grant amounts and counts by purpose, ordered by amount
#' @export
purpose_categories <- function(df) {
  if (!nrow(df)) return(tibble::tibble())
  pr <- as.character(df$purpose)
  df <- df[nzchar(pr) & !is.na(pr), , drop = FALSE]
  if (!nrow(df)) return(tibble::tibble())
  df |>
    dplyr::group_by(.data$purpose) |>
    dplyr::summarise(
      total_amount = sum(.data$total_amount, na.rm = TRUE),
      grant_count = dplyr::n(),
      regions = paste(sort(unique(as.character(.data$region))), collapse = "; "),
      .groups = "drop"
    ) |>
    dplyr::arrange(dplyr::desc(.data$total_amount))
}

#' Analyze grants by recipient country
#'
#' Groups grants by recipient country and calculates comprehensive
#' statistics including amounts, donor counts, and purposes.
#'
#' @param df Data frame containing foreign grants data
#' @return Tibble with grant statistics by recipient country
#' @export
country_analysis <- function(df) {
  if (!nrow(df)) return(tibble::tibble())
  rc <- as.character(df$recipient_country)
  df <- df[nzchar(rc) & !is.na(rc), , drop = FALSE]
  if (!nrow(df)) return(tibble::tibble())
  df |>
    dplyr::group_by(.data$recipient_country) |>
    dplyr::summarise(
      total_amount = sum(.data$total_amount, na.rm = TRUE),
      total_cash = sum(.data$cash_amount, na.rm = TRUE),
      total_non_cash = sum(.data$non_cash_amount, na.rm = TRUE),
      grant_count = dplyr::n(),
      unique_donors = dplyr::n_distinct(.data$ein),
      regions = paste(sort(unique(as.character(.data$region))), collapse = "; "),
      purposes = paste(
        utils::head(sort(unique(setdiff(as.character(.data$purpose), ""))), 5L),
        collapse = "; "
      ),
      .groups = "drop"
    ) |>
    dplyr::arrange(dplyr::desc(.data$total_amount))
}
