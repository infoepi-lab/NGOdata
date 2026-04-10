parse_header <- function(root, ns) {
  out <- list()
  for (nm in names(HEADER_FIELDS)) {
    out[[nm]] <- xml_find_first_try(root, HEADER_FIELDS[[nm]], ns)
  }
  out
}

#' Peek EIN from early lines of a 990 XML file
#' @param xml_path File path
#' @param max_lines Max lines to read
#' @export
peek_filing_ein <- function(xml_path, max_lines = 5000L) {
  if (!is.character(xml_path) || length(xml_path) != 1 || is.na(xml_path)) {
    stop("xml_path must be a single character string", call. = FALSE)
  }
  if (!file.exists(xml_path)) {
    stop("File does not exist: ", xml_path, call. = FALSE)
  }
  if (!is.numeric(max_lines) || length(max_lines) != 1 || is.na(max_lines) || max_lines < 1) {
    stop("max_lines must be a positive integer", call. = FALSE)
  }

  lines <- tryCatch(
    readLines(xml_path, n = max_lines, warn = FALSE, encoding = "UTF-8"),
    error = function(e) {
      stop("Failed to read file: ", xml_path, " - ", e$message, call. = FALSE)
    }
  )

  txt <- paste(lines, collapse = "\n")
  g <- regmatches(txt, regexec("<EIN[^>]*>([0-9\\-]+)</EIN>", txt, perl = TRUE))[[1L]]
  if (length(g) < 2L) return(NULL)
  ein <- gsub("-", "", g[2L], fixed = TRUE)
  if (nchar(ein) == 9L && grepl("^[0-9]+$", ein)) ein else NULL
}

parse_board_members <- function(root, ns, ein = "", tax_year = 0L) {
  groups <- xml_find_all_try(root, BOARD_MEMBER_GROUPS, ns)
  members <- list()
  if (!length(groups)) return(members)

  for (grp in groups) {
    name <- xml_find_first_try(grp, BOARD_MEMBER_FIELDS$person_name, ns)
    if (is.null(name)) {
      name <- xml_find_first_try(grp, BOARD_MEMBER_FIELDS$business_name, ns)
    }
    if (is.null(name)) next

    members[[length(members) + 1L]] <- list(
      name = name,
      title = xml_find_first_try(grp, BOARD_MEMBER_FIELDS$title, ns) %||% "",
      avg_hours_per_week = irs_to_float(
        xml_find_first_try(grp, BOARD_MEMBER_FIELDS$avg_hours, ns)
      ),
      avg_hours_related_orgs = irs_to_float(
        xml_find_first_try(grp, BOARD_MEMBER_FIELDS$avg_hours_related, ns)
      ),
      is_trustee_or_director = irs_is_true(
        xml_find_first_try(grp, BOARD_MEMBER_FIELDS$trustee_or_director, ns)
      ),
      is_officer = irs_is_true(
        xml_find_first_try(grp, BOARD_MEMBER_FIELDS$officer, ns)
      ),
      is_key_employee = irs_is_true(
        xml_find_first_try(grp, BOARD_MEMBER_FIELDS$key_employee, ns)
      ),
      is_highest_compensated = irs_is_true(
        xml_find_first_try(grp, BOARD_MEMBER_FIELDS$highest_compensated, ns)
      ),
      is_former = irs_is_true(
        xml_find_first_try(grp, BOARD_MEMBER_FIELDS$former, ns)
      ),
      reportable_comp_from_org = irs_to_decimal(
        xml_find_first_try(grp, BOARD_MEMBER_FIELDS$comp_from_org, ns)
      ),
      reportable_comp_from_related = irs_to_decimal(
        xml_find_first_try(grp, BOARD_MEMBER_FIELDS$comp_from_related, ns)
      ),
      other_compensation = irs_to_decimal(
        xml_find_first_try(grp, BOARD_MEMBER_FIELDS$other_comp, ns)
      ),
      ein = ein,
      tax_year = tax_year,
      source = "xml"
    )
  }
  members
}

parse_foreign_activities <- function(root, ns, ein = "", tax_year = 0L) {
  groups <- xml_find_all_try(root, FOREIGN_ACTIVITY_GROUPS, ns)
  out <- list()
  if (!length(groups)) return(out)

  for (grp in groups) {
    region <- xml_find_first_try(grp, FOREIGN_ACTIVITY_FIELDS$region, ns)
    if (is.null(region)) next
    out[[length(out) + 1L]] <- list(
      region = region,
      num_offices = irs_int0(
        xml_find_first_try(grp, FOREIGN_ACTIVITY_FIELDS$num_offices, ns)
      ),
      num_employees = irs_int0(
        xml_find_first_try(grp, FOREIGN_ACTIVITY_FIELDS$num_employees, ns)
      ),
      activities_conducted = xml_find_first_try(
        grp, FOREIGN_ACTIVITY_FIELDS$activities, ns
      ) %||% "",
      total_expenditures = irs_to_decimal(
        xml_find_first_try(grp, FOREIGN_ACTIVITY_FIELDS$expenditures, ns)
      ),
      ein = ein,
      tax_year = tax_year
    )
  }
  out
}

parse_foreign_org_grants <- function(root, ns, ein = "", tax_year = 0L) {
  groups <- xml_find_all_try(root, FOREIGN_ORG_GRANT_GROUPS, ns)
  out <- list()
  if (!length(groups)) return(out)

  for (grp in groups) {
    region <- xml_find_first_try(grp, FOREIGN_ORG_GRANT_FIELDS$region, ns)
    if (is.null(region)) region <- "Unknown"
    out[[length(out) + 1L]] <- list(
      region = region,
      purpose = xml_find_first_try(grp, FOREIGN_ORG_GRANT_FIELDS$purpose, ns) %||% "",
      cash_amount = irs_to_decimal(
        xml_find_first_try(grp, FOREIGN_ORG_GRANT_FIELDS$cash_amount, ns)
      ),
      non_cash_amount = irs_to_decimal(
        xml_find_first_try(grp, FOREIGN_ORG_GRANT_FIELDS$non_cash_amount, ns)
      ),
      manner_of_disbursement = xml_find_first_try(
        grp, FOREIGN_ORG_GRANT_FIELDS$manner_of_disbursement, ns
      ) %||% "",
      valuation_method = xml_find_first_try(
        grp, FOREIGN_ORG_GRANT_FIELDS$valuation_method, ns
      ) %||% "",
      recipient_count = irs_to_int(
        xml_find_first_try(grp, FOREIGN_ORG_GRANT_FIELDS$recipient_count, ns)
      ),
      recipient_name = xml_find_first_try(
        grp, FOREIGN_ORG_GRANT_FIELDS$recipient_name, ns
      ) %||% "",
      recipient_address = xml_find_first_try(
        grp, FOREIGN_ORG_GRANT_FIELDS$recipient_address, ns
      ) %||% "",
      recipient_country = xml_find_first_try(
        grp, FOREIGN_ORG_GRANT_FIELDS$recipient_country, ns
      ) %||% "",
      irs_section = xml_find_first_try(
        grp, FOREIGN_ORG_GRANT_FIELDS$irs_section, ns
      ) %||% "",
      ein = ein,
      tax_year = tax_year,
      source = "xml"
    )
  }
  out
}

parse_foreign_individual_grants <- function(root, ns, ein = "", tax_year = 0L) {
  groups <- xml_find_all_try(root, FOREIGN_INDIVIDUAL_GRANT_GROUPS, ns)
  out <- list()
  if (!length(groups)) return(out)

  for (grp in groups) {
    out[[length(out) + 1L]] <- list(
      activity_type = xml_find_first_try(
        grp, FOREIGN_INDIVIDUAL_GRANT_FIELDS$activity_type, ns
      ) %||% "",
      region = xml_find_first_try(
        grp, FOREIGN_INDIVIDUAL_GRANT_FIELDS$region, ns
      ) %||% "",
      recipient_count = irs_to_int(
        xml_find_first_try(grp, FOREIGN_INDIVIDUAL_GRANT_FIELDS$recipient_count, ns)
      ),
      cash_amount = irs_to_decimal(
        xml_find_first_try(grp, FOREIGN_INDIVIDUAL_GRANT_FIELDS$cash_amount, ns)
      ),
      manner_of_disbursement = xml_find_first_try(
        grp, FOREIGN_INDIVIDUAL_GRANT_FIELDS$manner_of_disbursement, ns
      ) %||% "",
      non_cash_amount = irs_to_decimal(
        xml_find_first_try(grp, FOREIGN_INDIVIDUAL_GRANT_FIELDS$non_cash_amount, ns)
      ),
      valuation_method = xml_find_first_try(
        grp, FOREIGN_INDIVIDUAL_GRANT_FIELDS$valuation_method, ns
      ) %||% "",
      non_cash_description = xml_find_first_try(
        grp, FOREIGN_INDIVIDUAL_GRANT_FIELDS$non_cash_description, ns
      ) %||% "",
      ein = ein,
      tax_year = tax_year
    )
  }
  out
}

#' Parse a 990 XML file into a filing list object
#' @param xml_path Path to XML
#' @export
parse_990_xml <- function(xml_path) {
  if (!is.character(xml_path) || length(xml_path) != 1 || is.na(xml_path)) {
    stop("xml_path must be a single character string", call. = FALSE)
  }
  if (!file.exists(xml_path)) {
    stop("XML file does not exist: ", xml_path, call. = FALSE)
  }

  doc <- tryCatch(
    xml2::read_xml(xml_path),
    error = function(e) {
      stop("Failed to parse XML file: ", xml_path, " - ", e$message, call. = FALSE)
    }
  )

  root <- xml2::xml_root(doc)
  if (is.null(root)) {
    stop("XML file has no root element: ", xml_path, call. = FALSE)
  }

  ns <- irs_xml_ns_map(root)
  header <- parse_header(root, ns)

  ein <- header$ein %||% ""
  ein <- gsub("-", "", ein, fixed = TRUE)

  ty <- suppressWarnings(as.integer(header$tax_year))
  if (is.na(ty)) {
    warning("Invalid or missing tax year in XML file: ", xml_path, call. = FALSE)
    ty <- 0L
  }

  # Validate that this looks like a Form 990
  form_type <- header$form_type %||% "990"
  if (!grepl("990", form_type, ignore.case = TRUE)) {
    warning("File does not appear to be a Form 990: ", xml_path, " (form type: ", form_type, ")", call. = FALSE)
  }

  list(
    ein = ein,
    organization_name = header$org_name %||% "",
    tax_year = ty,
    form_type = form_type,
    source = "xml",
    state = header$state %||% "",
    city = header$city %||% "",
    total_revenue = irs_to_float(header$total_revenue),
    total_expenses = irs_to_float(header$total_expenses),
    total_assets = irs_to_float(header$total_assets),
    board_members = parse_board_members(root, ns, ein, ty),
    foreign_grants = parse_foreign_org_grants(root, ns, ein, ty),
    foreign_activities = parse_foreign_activities(root, ns, ein, ty),
    foreign_individual_grants = parse_foreign_individual_grants(root, ns, ein, ty),
    raw_xml_path = normalizePath(xml_path, winslash = "/", mustWork = FALSE),
    raw_pdf_path = NULL,
    object_id = ""
  )
}
