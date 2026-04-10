#' Parse CLI args (mirrors `scripts/run_analysis.py` options)
#' @param argv Character vector (default: `commandArgs(trailingOnly = TRUE)`)
#' @export
parse_cli_args <- function(argv = commandArgs(trailingOnly = TRUE)) {
  eins <- character()
  ein_file <- NULL
  years_str <- "2017-2025"
  fetch <- TRUE
  do_parse <- TRUE
  analyze <- TRUE
  output <- NULL
  full <- FALSE
  project_root <- NULL
  i <- 1L
  while (i <= length(argv)) {
    a <- argv[[i]]
    if (a %in% c("--eins", "-e") && i < length(argv)) {
      eins <- c(eins, gsub("-", "", argv[[i + 1L]], fixed = TRUE))
      i <- i + 2L
    } else if (a %in% c("--file", "-f") && i < length(argv)) {
      ein_file <- argv[[i + 1L]]
      i <- i + 2L
    } else if (a %in% c("--years", "-y") && i < length(argv)) {
      years_str <- argv[[i + 1L]]
      i <- i + 2L
    } else if (a == "--no-fetch") {
      fetch <- FALSE
      i <- i + 1L
    } else if (a == "--fetch") {
      fetch <- TRUE
      i <- i + 1L
    } else if (a == "--no-parse") {
      do_parse <- FALSE
      i <- i + 1L
    } else if (a == "--parse") {
      do_parse <- TRUE
      i <- i + 1L
    } else if (a == "--no-analyze") {
      analyze <- FALSE
      i <- i + 1L
    } else if (a == "--analyze") {
      analyze <- TRUE
      i <- i + 1L
    } else if (a %in% c("--output", "-o") && i < length(argv)) {
      output <- argv[[i + 1L]]
      i <- i + 2L
    } else if (a == "--full") {
      full <- TRUE
      i <- i + 1L
    } else if (a %in% c("--project_root", "-r") && i < length(argv)) {
      project_root <- argv[[i + 1L]]
      i <- i + 2L
    } else {
      i <- i + 1L
    }
  }
  years <- if (grepl("-", years_str, fixed = TRUE)) {
    p <- strsplit(years_str, "-", fixed = TRUE)[[1L]]
    seq(as.integer(p[[1L]]), as.integer(p[[2L]]), by = 1L)
  } else {
    y <- as.integer(years_str)
    y:y
  }
  list(
    eins = eins,
    ein_file = ein_file,
    years = years,
    fetch = fetch,
    parse = do_parse,
    analyze = analyze,
    output_dir = output,
    full = full,
    project_root = project_root
  )
}

#' Full pipeline: fetch, parse, analyze, export
#'
#' @param eins Character vector of 9-digit EINs (no dashes required).
#' @param ein_file Optional path to text file (one EIN per line, `#` comments ok).
#' @param years Integer vector of IRS index years.
#' @param fetch,parse,analyze Logical toggles.
#' @param full If TRUE, sets fetch, parse, analyze all TRUE.
#' @param output_dir Override `paths$output_dir`.
#' @param project_root Repo root for [irs_project_paths()].
#' @param paths Optional pre-built paths list.
#' @param argv Character vector of command line arguments for CLI version
#' @export
run_irs990_pipeline <- function(
    eins = character(),
    ein_file = NULL,
    years = 2017:2025,
    fetch = TRUE,
    parse = TRUE,
    analyze = TRUE,
    output_dir = NULL,
    full = FALSE,
    project_root = NULL,
    paths = NULL
) {
  if (isTRUE(full)) {
    fetch <- parse <- analyze <- TRUE
  }
  p <- paths %||% irs_project_paths(project_root)
  irs_ensure_dirs(p)
  if (!is.null(output_dir)) {
    dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
    p$output_dir <- normalizePath(output_dir, winslash = "/", mustWork = TRUE)
  }

  ein_list <- unique(c(eins, if (!is.null(ein_file) && nzchar(ein_file) && file.exists(ein_file)) {
    lines <- readLines(ein_file, warn = FALSE)
    lines <- sub("#.*$", "", lines)
    lines <- gsub("-", "", trimws(lines), fixed = TRUE)
    lines[nzchar(lines) & grepl("^[0-9]+$", lines)]
  } else character()))

  if (!length(ein_list)) {
    stop("No EINs provided. Use eins= or ein_file=.", call. = FALSE)
  }

  message(sprintf(
    "EINs: %d | Years: %d-%d | Output: %s",
    length(ein_list), min(years), max(years), p$output_dir
  ))

  xml_paths <- character()
  if (fetch) {
    message("\n", strrep("=", 60L), "\nSTEP 1: FETCH\n", strrep("=", 60L))
    xml_paths <- irs_smart_fetch(ein_list, years, p)
    message(sprintf("\nTotal XML paths: %d", length(xml_paths)))
  }

  filings <- list()
  if (parse) {
    message("\n", strrep("=", 60L), "\nSTEP 2: PARSE\n", strrep("=", 60L))
    all_xml <- list.files(
      p$raw_xml_dir,
      pattern = "\\.xml$",
      ignore.case = TRUE,
      full.names = TRUE
    )
    if (length(xml_paths)) {
      xf <- unique(normalizePath(xml_paths, winslash = "/", mustWork = FALSE))
      extra <- all_xml[vapply(all_xml, function(fp) {
        stem <- sub("\\.xml$", "", basename(fp), ignore.case = TRUE)
        any(vapply(ein_list, function(e) grepl(e, stem, fixed = TRUE), logical(1L)))
      }, logical(1L))]
      all_xml <- unique(c(xf, extra))
    }
    if (!length(all_xml)) {
      stop("No XML files found in ", p$raw_xml_dir, call. = FALSE)
    }
    message(sprintf("Parsing %d XML files...\n", length(all_xml)))
    for (fp in all_xml) {
      filing <- tryCatch(
        parse_990_xml(fp),
        error = function(e) {
          message(sprintf("  ERROR %s: %s", basename(fp), conditionMessage(e)))
          NULL
        }
      )
      if (is.null(filing)) next
      fn_ein <- gsub("-", "", filing$ein, fixed = TRUE)
      if (!fn_ein %in% ein_list) next
      filings <- c(filings, list(filing))
      message(sprintf(
        "  %-40s (%s, TY%s) | %2d board | %2d foreign grants",
        substr(filing$organization_name %||% "", 1L, 40L),
        filing$ein,
        filing$tax_year,
        length(filing$board_members),
        length(filing$foreign_grants)
      ))
    }
    message(sprintf("\nParsed: %d filings", length(filings)))
  }

  if (analyze && length(filings)) {
    message("\n", strrep("=", 60L), "\nSTEP 3: ANALYZE & EXPORT\n", strrep("=", 60L))
    all_board <- unlist(lapply(filings, `[[`, "board_members"), recursive = FALSE)
    all_grants <- unlist(lapply(filings, `[[`, "foreign_grants"), recursive = FALSE)
    all_act <- unlist(lapply(filings, `[[`, "foreign_activities"), recursive = FALSE)
    all_ind <- unlist(lapply(filings, `[[`, "foreign_individual_grants"), recursive = FALSE)

    board_df <- board_members_to_tibble(all_board)
    grants_df <- foreign_grants_to_tibble(all_grants)
    activities_df <- foreign_activities_to_tibble(all_act)
    indiv_df <- foreign_individual_grants_to_tibble(all_ind)

    filing_rows <- lapply(filings, filing_summary)
    filing_df <- dplyr::bind_rows(filing_rows)
    ded <- tibble::tibble()

    message(sprintf("\nOrganizations: %d", dplyr::n_distinct(filing_df$ein)))
    message(sprintf("Total filings: %d", nrow(filing_df)))

    if (nrow(board_df)) {
      ded <- deduplicate_board_members(board_df)
      message(sprintf("\nUnique board rows (deduped): %d", nrow(ded)))
      print(as.data.frame(role_distribution(board_df)))
    }
    if (nrow(grants_df)) {
      message("\nGrants by region:")
      print(as.data.frame(grants_by_region(grants_df)))
    }

    irs_export_csv(filing_df, "filing_summaries.csv", p$output_dir)
    if (nrow(board_df)) {
      irs_export_csv(board_df, "board_members.csv", p$output_dir)
      irs_export_csv(ded, "board_members_deduped.csv", p$output_dir)
      irs_export_json(board_df, "board_members.json", p$output_dir)
    }
    if (nrow(grants_df)) {
      irs_export_csv(grants_df, "foreign_grants.csv", p$output_dir)
      irs_export_json(grants_df, "foreign_grants.json", p$output_dir)
    }
    if (nrow(activities_df)) {
      irs_export_csv(activities_df, "foreign_activities.csv", p$output_dir)
    }
    if (nrow(indiv_df)) {
      irs_export_csv(indiv_df, "foreign_individual_grants.csv", p$output_dir)
    }
    irs_export_full_analysis(board_df, grants_df, activities_df, indiv_df, p$output_dir)
    message(sprintf("\nResults in: %s/", p$output_dir))
  } else if (analyze && !length(filings)) {
    message(
      "\nNo filings to analyze. Check EINs, year range, and XML under data/raw/xml/."
    )
  }

  invisible(list(filings = filings, paths = p))
}

#' @rdname run_irs990_pipeline
#' @export
run_irs990_pipeline_cli <- function(argv = commandArgs(trailingOnly = TRUE)) {
  a <- parse_cli_args(argv)
  do.call(run_irs990_pipeline, a)
}
