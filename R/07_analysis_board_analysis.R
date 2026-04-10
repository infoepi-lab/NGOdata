#' Generate compensation summary statistics
#'
#' Produces summary statistics for compensation columns in board member data.
#'
#' @param df Data frame containing board member compensation data
#' @return Tibble with compensation summary statistics
#' @export
compensation_summary <- function(df) {
  if (!nrow(df)) return(tibble::tibble())
  cols <- intersect(
    c(
      "reportable_comp_from_org", "reportable_comp_from_related",
      "other_compensation", "total_compensation"
    ),
    names(df)
  )
  if (!length(cols)) return(tibble::tibble())
  sm <- summary(df[cols])
  tibble::tibble(stat = rownames(sm), value = apply(sm, 1L, paste, collapse = " "))
}

#' Find top compensated board members
#'
#' Returns the highest compensated individuals from board member data.
#'
#' @param df Data frame containing board member data with compensation
#' @param n Number of top compensated individuals to return (default 20)
#' @return Tibble with top compensated board members
#' @export
top_compensated <- function(df, n = 20L) {
  if (!nrow(df)) return(tibble::tibble())
  cols <- intersect(
    c(
      "name", "title", "ein", "tax_year", "roles",
      "total_compensation", "reportable_comp_from_org"
    ),
    names(df)
  )
  df |>
    dplyr::slice_max(order_by = .data$total_compensation, n = n, with_ties = FALSE) |>
    dplyr::select(dplyr::all_of(cols))
}

#' Analyze board member role distribution
#'
#' Counts the distribution of different roles among board members.
#'
#' @param df Data frame containing board member data with role indicators
#' @return Tibble with role counts
#' @export
role_distribution <- function(df) {
  if (!nrow(df)) return(tibble::tibble())
  role_cols <- c(
    "is_trustee_or_director", "is_officer", "is_key_employee",
    "is_highest_compensated", "is_former"
  )
  labels <- c(
    "Trustees/Directors", "Officers", "Key Employees",
    "Highest Compensated", "Former Officers/Directors"
  )
  present <- intersect(role_cols, names(df))
  if (!length(present)) return(tibble::tibble())
  idx <- match(present, role_cols)
  counts <- vapply(present, function(cn) {
    sum(df[[cn]] %in% TRUE | df[[cn]] == 1L, na.rm = TRUE)
  }, numeric(1))
  tibble::tibble(role = labels[idx], count = as.numeric(counts))
}

#' Calculate board size metrics by organization
#'
#' Summarizes board size and compensation by organization and tax year.
#' One row per `(ein, tax_year)` pair.
#'
#' @param df A tibble of board members as returned by
#'   [board_members_to_tibble()]. Must contain columns `ein`, `tax_year`,
#'   and `total_compensation`. If you have a path to a 990 XML file, first
#'   call [parse_990_xml()] on it and then pass
#'   `board_members_to_tibble(filing$board_members)` here.
#' @return Tibble with columns `ein`, `tax_year`, `board_size`,
#'   `total_comp`, `avg_comp`.
#' @seealso [parse_990_xml()], [board_members_to_tibble()],
#'   [compensation_summary()], [cross_board_membership()]
#' @examples
#' \dontrun{
#' filing   <- parse_990_xml("path/to/990.xml")
#' board_df <- board_members_to_tibble(filing$board_members)
#' board_size_by_org(board_df)
#' }
#' @export
board_size_by_org <- function(df) {
  if (!nrow(df)) return(tibble::tibble())
  df |>
    dplyr::group_by(.data$ein, .data$tax_year) |>
    dplyr::summarise(
      board_size = dplyr::n(),
      total_comp = sum(.data$total_compensation, na.rm = TRUE),
      avg_comp = mean(.data$total_compensation, na.rm = TRUE),
      .groups = "drop"
    ) |>
    dplyr::arrange(.data$ein, .data$tax_year)
}

#' Identify individuals serving on multiple boards
#'
#' Analyzes cross-board membership by identifying individuals who serve
#' on multiple organization boards.
#'
#' @param df Data frame containing board member data
#' @return Tibble with individuals serving on multiple boards
#' @export
cross_board_membership <- function(df) {
  if (!nrow(df)) return(tibble::tibble())
  df |>
    dplyr::mutate(name_normalized = stringr::str_squish(toupper(as.character(.data$name)))) |>
    dplyr::group_by(.data$name_normalized) |>
    dplyr::summarise(
      organizations = dplyr::n_distinct(.data$ein),
      ein_list = paste(sort(unique(as.character(.data$ein))), collapse = ", "),
      years_active = paste(range(.data$tax_year, na.rm = TRUE), collapse = "-"),
      names_used = paste(sort(unique(as.character(.data$name))), collapse = "; "),
      .groups = "drop"
    ) |>
    dplyr::filter(.data$organizations > 1) |>
    dplyr::arrange(dplyr::desc(.data$organizations))
}
