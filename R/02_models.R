board_member_roles <- function(m) {
  roles <- character()
  if (isTRUE(m$is_trustee_or_director)) roles <- c(roles, "Trustee/Director")
  if (isTRUE(m$is_officer)) roles <- c(roles, "Officer")
  if (isTRUE(m$is_key_employee)) roles <- c(roles, "Key Employee")
  if (isTRUE(m$is_highest_compensated)) roles <- c(roles, "Highest Compensated")
  if (isTRUE(m$is_former)) roles <- c(roles, "Former")
  roles
}

board_member_total_comp <- function(m) {
  sum(
    c(
      m$reportable_comp_from_org %||% 0,
      m$reportable_comp_from_related %||% 0,
      m$other_compensation %||% 0
    ),
    na.rm = TRUE
  )
}

board_member_to_list <- function(m) {
  list(
    name = m$name,
    title = m$title %||% "",
    avg_hours_per_week = m$avg_hours_per_week,
    avg_hours_related_orgs = m$avg_hours_related_orgs,
    roles = paste(board_member_roles(m), collapse = ", "),
    is_trustee_or_director = isTRUE(m$is_trustee_or_director),
    is_officer = isTRUE(m$is_officer),
    is_key_employee = isTRUE(m$is_key_employee),
    is_highest_compensated = isTRUE(m$is_highest_compensated),
    is_former = isTRUE(m$is_former),
    reportable_comp_from_org = m$reportable_comp_from_org %||% 0,
    reportable_comp_from_related = m$reportable_comp_from_related %||% 0,
    other_compensation = m$other_compensation %||% 0,
    total_compensation = board_member_total_comp(m),
    ein = m$ein %||% "",
    tax_year = m$tax_year %||% 0L,
    source = m$source %||% "xml"
  )
}

foreign_grant_total <- function(g) {
  (g$cash_amount %||% 0) + (g$non_cash_amount %||% 0)
}

foreign_activity_to_list <- function(a) {
  list(
    region = a$region,
    num_offices = a$num_offices %||% 0L,
    num_employees = a$num_employees %||% 0L,
    activities_conducted = a$activities_conducted %||% "",
    total_expenditures = a$total_expenditures %||% 0,
    ein = a$ein %||% "",
    tax_year = a$tax_year %||% 0L
  )
}

foreign_grant_to_list <- function(g) {
  list(
    region = g$region,
    purpose = g$purpose %||% "",
    cash_amount = g$cash_amount %||% 0,
    non_cash_amount = g$non_cash_amount %||% 0,
    total_amount = foreign_grant_total(g),
    manner_of_disbursement = g$manner_of_disbursement %||% "",
    valuation_method = g$valuation_method %||% "",
    recipient_count = g$recipient_count,
    recipient_name = g$recipient_name %||% "",
    recipient_address = g$recipient_address %||% "",
    recipient_country = g$recipient_country %||% "",
    irs_section = g$irs_section %||% "",
    ein = g$ein %||% "",
    tax_year = g$tax_year %||% 0L,
    source = g$source %||% "xml"
  )
}

foreign_individual_grant_to_list <- function(g) {
  list(
    activity_type = g$activity_type %||% "",
    region = g$region %||% "",
    recipient_count = g$recipient_count,
    cash_amount = g$cash_amount %||% 0,
    manner_of_disbursement = g$manner_of_disbursement %||% "",
    non_cash_amount = g$non_cash_amount %||% 0,
    valuation_method = g$valuation_method %||% "",
    non_cash_description = g$non_cash_description %||% "",
    ein = g$ein %||% "",
    tax_year = g$tax_year %||% 0L
  )
}

filing_summary <- function(f) {
  cash_sum <- sum(
    vapply(f$foreign_grants, \(g) g$cash_amount %||% 0, numeric(1)),
    na.rm = TRUE
  )
  list(
    ein = f$ein,
    organization_name = f$organization_name,
    tax_year = f$tax_year,
    form_type = f$form_type %||% "990",
    state = f$state %||% "",
    board_member_count = length(f$board_members),
    foreign_grant_count = length(f$foreign_grants),
    foreign_activity_regions = length(f$foreign_activities),
    total_foreign_grant_cash = cash_sum
  )
}
