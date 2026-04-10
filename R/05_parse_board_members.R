#' Convert board member list to tibble
#'
#' Transforms a list of board member objects into a tibble data frame.
#'
#' @param members List of board member objects
#' @return Tibble containing board member data
#' @export
board_members_to_tibble <- function(members) {
  if (!length(members)) {
    return(tibble::tibble())
  }
  rows <- lapply(members, board_member_to_list)
  dplyr::bind_rows(rows)
}

#' Remove duplicate board member entries
#'
#' Removes duplicate board member records, keeping the most recent entry
#' for each person-organization combination.
#'
#' @param df Data frame containing board member data
#' @return Data frame with duplicates removed
#' @export
deduplicate_board_members <- function(df) {
  if (!nrow(df)) return(df)
  df |>
    dplyr::arrange(dplyr::desc(.data$tax_year)) |>
    dplyr::distinct(.data$ein, .data$name, .keep_all = TRUE) |>
    dplyr::arrange(.data$ein, .data$name)
}

#' Analyze board member tenure
#'
#' Calculates tenure metrics for board members including years served
#' and titles held across multiple filings.
#'
#' @param df Data frame containing board member data across multiple years
#' @return Tibble with tenure analysis for each board member
#' @export
board_tenure_analysis <- function(df) {
  if (!nrow(df)) return(tibble::tibble())
  df |>
    dplyr::group_by(.data$ein, .data$name) |>
    dplyr::summarise(
      first_year = min(.data$tax_year, na.rm = TRUE),
      last_year = max(.data$tax_year, na.rm = TRUE),
      years_served = dplyr::n_distinct(.data$tax_year),
      titles = paste(sort(unique(as.character(.data$title))), collapse = "; "),
      .groups = "drop"
    )
}
