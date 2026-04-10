test_that("CLI argument parsing works correctly", {
  # Test basic argument parsing
  args1 <- c("--eins", "123456789", "--years", "2020-2022")
  result1 <- parse_cli_args(args1)

  expect_equal(result1$eins, "123456789")
  expect_equal(result1$years, c(2020L, 2021L, 2022L))
  expect_true(result1$fetch)
  expect_true(result1$parse)
  expect_true(result1$analyze)

  # Test flag options
  args2 <- c("--no-fetch", "--no-parse", "--no-analyze")
  result2 <- parse_cli_args(args2)

  expect_false(result2$fetch)
  expect_false(result2$parse)
  expect_false(result2$analyze)

  # Test file option
  args3 <- c("--file", "test.txt", "--output", "results")
  result3 <- parse_cli_args(args3)

  expect_equal(result3$ein_file, "test.txt")
  expect_equal(result3$output_dir, "results")

  # Test full flag
  args4 <- c("--full")
  result4 <- parse_cli_args(args4)

  expect_true(result4$full)

  # Test multiple EINs
  args5 <- c("--eins", "123456789", "--eins", "987654321")
  result5 <- parse_cli_args(args5)

  expect_equal(length(result5$eins), 2)
  expect_true("123456789" %in% result5$eins)
  expect_true("987654321" %in% result5$eins)
})

test_that("CLI parsing handles edge cases", {
  # Test empty args
  result_empty <- parse_cli_args(character())
  expect_equal(result_empty$years, 2017:2025)  # default
  expect_true(result_empty$fetch)  # default
  expect_length(result_empty$eins, 0)

  # Test hyphen removal in EINs
  args_hyphen <- c("--eins", "12-3456789")
  result_hyphen <- parse_cli_args(args_hyphen)
  expect_equal(result_hyphen$eins, "123456789")

  # Test unknown arguments (should be ignored)
  args_unknown <- c("--unknown-flag", "value", "--eins", "123456789")
  result_unknown <- parse_cli_args(args_unknown)
  expect_equal(result_unknown$eins, "123456789")
})

# Mock tests for network functions (these would need actual mocking in real tests)
test_that("data acquisition functions have proper structure", {
  # Test that functions exist and have expected signatures
  expect_true(exists("irs_download_index"))
  expect_true(exists("irs_search_index"))
  expect_true(exists("irs_fetch_eins_for_year"))
  expect_true(exists("irs_smart_fetch"))

  # Check function formals (parameters)
  expect_named(formals(irs_download_index), c("year", "paths"))
  expect_named(formals(irs_search_index), c("year", "eins", "paths", "cache_env"))
})

test_that("export functions work correctly", {
  # Create test data
  test_data <- tibble::tibble(
    ein = c("123456789", "987654321"),
    name = c("Test Org 1", "Test Org 2"),
    revenue = c(50000, 75000)
  )

  # Test CSV export
  temp_dir <- tempdir()
  irs_export_csv(test_data, "test_data.csv", temp_dir)

  temp_csv <- file.path(temp_dir, "test_data.csv")
  expect_true(file.exists(temp_csv))
  read_back <- readr::read_csv(temp_csv, show_col_types = FALSE)
  expect_equal(nrow(read_back), 2)
  expect_equal(as.character(read_back$ein), test_data$ein)

  unlink(temp_csv)

  # Test JSON export (if it exists)
  if (exists("irs_export_json")) {
    irs_export_json(test_data, "test_data.json", temp_dir)

    temp_json <- file.path(temp_dir, "test_data.json")
    expect_true(file.exists(temp_json))
    json_content <- jsonlite::read_json(temp_json)
    expect_length(json_content, 2)
    expect_equal(json_content[[1]]$ein, "123456789")

    unlink(temp_json)
  }
})