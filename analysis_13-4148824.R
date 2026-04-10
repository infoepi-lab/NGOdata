#!/usr/bin/env Rscript
# ── Analysis of EIN 13-4148824 ──────────────────────────────────────────────
# Run from: irs-data/R/irs990/
# Usage:    Rscript analysis_13-4148824.R

library(infoepi.NGOdata)

ein <- "943074600"
years <- 2017:2023  # IRS bulk XML data available 2017+
output_dir <- file.path("output", "134148824")

# ── 1. Fetch & parse via pipeline ────────────────────────────────────────────
result <- run_irs990_pipeline(
  eins       = ein,
  years      = years,
  fetch      = TRUE,
  parse      = TRUE,
  analyze    = TRUE,
  output_dir = output_dir
)

# ── 2. Manual deep-dive (if you want more control) ──────────────────────────
paths     <- irs_project_paths()
xml_files <- irs_smart_fetch(ein, years, paths)

if (length(xml_files) == 0) {
  stop("No filings found for EIN ", ein, " in years ", paste(range(years), collapse = "-"))
}

cat("\n=== Found", length(xml_files), "filings ===\n\n")

filings <- lapply(xml_files, parse_990_xml)

# ── 3. Filing overview ──────────────────────────────────────────────────────
for (f in filings) {
  cat(sprintf(
    "  %s | %s | Revenue: $%s | Expenses: $%s | Assets: $%s | Board: %d | Grants: %d\n",
    f$tax_year,
    f$organization_name,
    format(as.numeric(f$total_revenue), big.mark = ",", scientific = FALSE),
    format(as.numeric(f$total_expenses), big.mark = ",", scientific = FALSE),
    format(as.numeric(f$total_assets), big.mark = ",", scientific = FALSE),
    length(f$board_members),
    length(f$foreign_grants)
  ))
}

# ── 4. Board analysis ───────────────────────────────────────────────────────
all_board <- unlist(lapply(filings, `[[`, "board_members"), recursive = FALSE)
board_df  <- board_members_to_tibble(all_board)

if (nrow(board_df) > 0) {
  cat("\n=== Board Analysis ===\n")
  cat("Total board member records:", nrow(board_df), "\n")

  deduped   <- deduplicate_board_members(board_df)
  cat("Unique individuals:", nrow(deduped), "\n")

  tenure    <- board_tenure_analysis(board_df)
  cat("\nTenure analysis:\n")
  print(tenure, n = 20)

  comp      <- compensation_summary(board_df)
  cat("\nCompensation summary:\n")
  print(comp)

  top_paid  <- top_compensated(board_df, n = 10)
  cat("\nTop 10 compensated:\n")
  print(top_paid, n = 10, width = Inf)

  roles     <- role_distribution(board_df)
  cat("\nRole distribution:\n")
  print(roles)

  sizes     <- board_size_by_org(board_df)
  cat("\nBoard size by org-year:\n")
  print(sizes, n = 20)

  cross     <- cross_board_membership(board_df)
  if (nrow(cross) > 0) {
    cat("\nCross-board membership:\n")
    print(cross, n = 20)
  }
} else {
  cat("\nNo board member data found.\n")
}

# ── 5. Foreign grants analysis ──────────────────────────────────────────────
all_grants <- unlist(lapply(filings, `[[`, "foreign_grants"), recursive = FALSE)
grants_df  <- foreign_grants_to_tibble(all_grants)

if (nrow(grants_df) > 0) {
  cat("\n=== Foreign Grants Analysis ===\n")
  cat("Total grant records:", nrow(grants_df), "\n")

  by_region  <- grants_by_region(grants_df)
  cat("\nGrants by region:\n")
  print(by_region, width = Inf)

  by_country <- grants_by_country(grants_df)
  cat("\nGrants by country:\n")
  print(by_country, n = 30, width = Inf)

  by_year    <- grants_by_year(grants_df)
  cat("\nGrants by year:\n")
  print(by_year, width = Inf)

  trends     <- grant_trends(grants_df)
  cat("\nGrant trends:\n")
  print(trends, width = Inf)

  top_recip  <- top_recipients(grants_df, n = 15)
  cat("\nTop 15 recipients:\n")
  print(top_recip, n = 15, width = Inf)

  purposes   <- purpose_categories(grants_df)
  cat("\nGrant purposes:\n")
  print(purposes, n = 20, width = Inf)

  countries  <- country_analysis(grants_df)
  cat("\nCountry analysis:\n")
  print(countries, n = 30, width = Inf)

  heatmap    <- regional_heatmap_data(grants_df)
  cat("\nRegional heatmap (region x year):\n")
  print(heatmap, width = Inf)
} else {
  cat("\nNo foreign grants data found.\n")
}

# ── 6. Foreign activities & individual grants ───────────────────────────────
all_activities <- unlist(lapply(filings, `[[`, "foreign_activities"), recursive = FALSE)
activities_df  <- foreign_activities_to_tibble(all_activities)

all_indiv      <- unlist(lapply(filings, `[[`, "foreign_individual_grants"), recursive = FALSE)
indiv_df       <- foreign_individual_grants_to_tibble(all_indiv)

if (nrow(activities_df) > 0) {
  cat("\n=== Foreign Activities ===\n")
  print(activities_df, n = 30, width = Inf)
}

if (nrow(indiv_df) > 0) {
  cat("\n=== Individual Grants ===\n")
  print(indiv_df, n = 30, width = Inf)
}

# ── 7. Export everything ────────────────────────────────────────────────────
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

irs_export_filing_summary(filings, output_dir)
irs_export_csv(board_df, "board_members.csv", output_dir)
irs_export_csv(grants_df, "foreign_grants.csv", output_dir)
irs_export_json(filings, "filings.json", output_dir)

irs_export_full_analysis(
  board_df       = board_df,
  grants_df      = grants_df,
  activities_df  = if (nrow(activities_df) > 0) activities_df else NULL,
  individual_grants_df = if (nrow(indiv_df) > 0) indiv_df else NULL,
  output_dir     = output_dir
)

cat("\n=== Output saved to:", normalizePath(output_dir), "===\n")
cat("Files:\n")
cat(paste(" ", list.files(output_dir, recursive = TRUE)), sep = "\n")
