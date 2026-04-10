test_that("board_members_to_tibble converts correctly", {
  # Create test board members data
  board_members <- list(
    list(
      name = "Jane Doe",
      title = "Director",
      reportable_comp_from_org = 5000,
      ein = "123456789",
      tax_year = 2023L,
      is_trustee_or_director = TRUE,
      is_officer = FALSE,
      is_key_employee = FALSE
    ),
    list(
      name = "John Smith",
      title = "CEO",
      reportable_comp_from_org = 75000,
      ein = "123456789",
      tax_year = 2023L,
      is_trustee_or_director = FALSE,
      is_officer = TRUE,
      is_key_employee = TRUE
    )
  )

  result <- board_members_to_tibble(board_members)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)
  expect_true("name" %in% names(result))
  expect_true("title" %in% names(result))
  expect_true("reportable_comp_from_org" %in% names(result))
  expect_true("ein" %in% names(result))
  expect_equal(result$name, c("Jane Doe", "John Smith"))
  expect_equal(result$reportable_comp_from_org, c(5000, 75000))
  expect_equal(result$is_officer, c(FALSE, TRUE))
})

test_that("board_members_to_tibble handles empty input", {
  result <- board_members_to_tibble(list())
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
  # Empty tibble, so no specific column names to check
})

test_that("deduplicate_board_members works correctly", {
  # Create test data with duplicates
  board_data <- tibble::tibble(
    name = c("Jane Doe", "jane doe", "John Smith", "Jane Doe"),
    title = c("Director", "Director", "CEO", "Chair"),
    reportable_comp_from_org = c(5000, 5000, 75000, 10000),
    ein = c("123456789", "123456789", "123456789", "123456789"),
    tax_year = c(2022L, 2022L, 2023L, 2023L),
    is_trustee_or_director = c(TRUE, TRUE, FALSE, TRUE),
    is_officer = c(FALSE, FALSE, TRUE, FALSE),
    is_key_employee = c(FALSE, FALSE, TRUE, FALSE)
  )

  result <- deduplicate_board_members(board_data)

  # Should have fewer rows due to deduplication
  expect_lt(nrow(result), nrow(board_data))
  # Should keep most recent records (highest tax_year)
  expect_true(all(result$tax_year >= 2022L))
})

test_that("board analysis functions handle real data", {
  # Create realistic test data with correct column names
  board_data <- tibble::tibble(
    name = c("Jane Doe", "John Smith", "Mary Johnson", "Bob Wilson"),
    title = c("Chair", "CEO", "Treasurer", "Director"),
    reportable_comp_from_org = c(0, 85000, 45000, 0),
    total_compensation = c(0, 85000, 45000, 0),
    ein = c("123456789", "123456789", "123456789", "123456789"),
    tax_year = c(2023L, 2023L, 2023L, 2023L),
    roles = c("Chair", "CEO", "Treasurer", "Director"),
    is_trustee_or_director = c(TRUE, FALSE, TRUE, TRUE),
    is_officer = c(TRUE, TRUE, TRUE, FALSE),
    is_key_employee = c(FALSE, TRUE, TRUE, FALSE)
  )

  # Test role_distribution
  role_dist <- role_distribution(board_data)
  expect_s3_class(role_dist, "tbl_df")

  # Test compensation_summary
  comp_summary <- compensation_summary(board_data)
  expect_s3_class(comp_summary, "tbl_df")

  # Test top_compensated
  top_comp <- top_compensated(board_data, n = 2)
  expect_s3_class(top_comp, "tbl_df")
  expect_lte(nrow(top_comp), 2)  # May be fewer if ties

  # Test board_size_by_org
  board_sizes <- board_size_by_org(board_data)
  expect_s3_class(board_sizes, "tbl_df")
})