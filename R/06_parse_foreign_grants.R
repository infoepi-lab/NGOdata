#' Convert foreign activities list to tibble
#'
#' Transforms a list of foreign activity objects into a tibble data frame.
#'
#' @param activities List of foreign activity objects
#' @return Tibble containing foreign activities data
#' @export
foreign_activities_to_tibble <- function(activities) {
  if (!length(activities)) return(tibble::tibble())
  dplyr::bind_rows(lapply(activities, foreign_activity_to_list))
}

#' Convert foreign individual grants list to tibble
#'
#' Transforms a list of foreign individual grant objects into a tibble data frame.
#'
#' @param grants List of foreign individual grant objects
#' @return Tibble containing foreign individual grants data
#' @export
foreign_individual_grants_to_tibble <- function(grants) {
  if (!length(grants)) return(tibble::tibble())
  dplyr::bind_rows(lapply(grants, foreign_individual_grant_to_list))
}

#' Convert foreign grants list to tibble
#'
#' Transforms a list of foreign grant objects into a tibble data frame.
#'
#' @param grants List of foreign grant objects
#' @return Tibble containing foreign grants data
#' @export
foreign_grants_to_tibble <- function(grants) {
  if (!length(grants)) return(tibble::tibble())
  dplyr::bind_rows(lapply(grants, foreign_grant_to_list))
}

#' Summarize grants by geographic region
#'
#' Groups foreign grants by region and calculates summary statistics
#' including total amounts, counts, and recipients.
#'
#' @param df Data frame containing foreign grants data
#' @return Tibble with grant summaries by region
#' @export
grants_by_region <- function(df) {
  if (!nrow(df)) return(tibble::tibble())
  df |>
    dplyr::group_by(.data$region) |>
    dplyr::summarise(
      total_cash = sum(.data$cash_amount, na.rm = TRUE),
      total_non_cash = sum(.data$non_cash_amount, na.rm = TRUE),
      total_amount = sum(.data$total_amount, na.rm = TRUE),
      grant_count = dplyr::n(),
      total_recipients = sum(.data$recipient_count, na.rm = TRUE),
      unique_purposes = dplyr::n_distinct(.data$purpose),
      .groups = "drop"
    ) |>
    dplyr::arrange(dplyr::desc(.data$total_amount))
}

#' Summarize grants by recipient country
#'
#' Groups foreign grants by recipient country and calculates summary statistics.
#'
#' @param df Data frame containing foreign grants data
#' @return Tibble with grant summaries by country
#' @export
grants_by_country <- function(df) {
  if (!nrow(df)) return(tibble::tibble())
  rc <- as.character(df$recipient_country)
  df <- df[nzchar(rc) & !is.na(rc), , drop = FALSE]
  if (!nrow(df)) return(tibble::tibble())
  df |>
    dplyr::group_by(.data$recipient_country) |>
    dplyr::summarise(
      total_cash = sum(.data$cash_amount, na.rm = TRUE),
      total_amount = sum(.data$total_amount, na.rm = TRUE),
      grant_count = dplyr::n(),
      regions = paste(sort(unique(as.character(.data$region))), collapse = "; "),
      .groups = "drop"
    ) |>
    dplyr::arrange(dplyr::desc(.data$total_amount))
}

#' Summarize grants by tax year
#'
#' Groups foreign grants by tax year and calculates temporal trends
#' in grant amounts and counts.
#'
#' @param df Data frame containing foreign grants data
#' @return Tibble with grant summaries by year
#' @export
grants_by_year <- function(df) {
  if (!nrow(df)) return(tibble::tibble())
  df |>
    dplyr::group_by(.data$tax_year) |>
    dplyr::summarise(
      total_cash = sum(.data$cash_amount, na.rm = TRUE),
      total_non_cash = sum(.data$non_cash_amount, na.rm = TRUE),
      total_amount = sum(.data$total_amount, na.rm = TRUE),
      grant_count = dplyr::n(),
      .groups = "drop"
    ) |>
    dplyr::arrange(.data$tax_year)
}

#' Create EIN-by-region grant matrix
#'
#' Generates a wide-format matrix showing grant amounts by organization (EIN)
#' and region, useful for comparative analysis.
#'
#' @param df Data frame containing foreign grants data
#' @return Tibble with EINs as rows and regions as columns
#' @export
grants_by_ein_and_region <- function(df) {
  if (!nrow(df)) return(tibble::tibble())
  w <- df |>
    dplyr::group_by(.data$ein, .data$region) |>
    dplyr::summarise(
      total_amount = sum(.data$total_amount, na.rm = TRUE),
      grant_count = dplyr::n(),
      .groups = "drop"
    )
  tidyr::pivot_wider(
    w,
    id_cols = "ein",
    names_from = "region",
    values_from = "total_amount",
    values_fill = 0
  )
}
