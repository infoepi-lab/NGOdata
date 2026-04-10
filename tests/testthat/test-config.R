test_that("project paths work correctly", {
  # Test default behavior
  paths <- irs_project_paths()
  expect_type(paths, "list")
  expect_named(paths, c("project_root", "data_dir", "raw_xml_dir",
                       "raw_pdf_dir", "index_dir", "ocr_dir", "output_dir"))
  expect_true(file.exists(paths$project_root))

  # Test with explicit root
  temp_root <- tempdir()
  paths2 <- irs_project_paths(temp_root)
  expect_equal(paths2$project_root, normalizePath(temp_root, winslash = "/"))
})

test_that("directory creation works", {
  temp_root <- tempdir()
  test_paths <- list(
    project_root = temp_root,
    data_dir = file.path(temp_root, "data"),
    raw_xml_dir = file.path(temp_root, "data", "raw", "xml"),
    raw_pdf_dir = file.path(temp_root, "data", "raw", "pdf"),
    index_dir = file.path(temp_root, "data", "index"),
    ocr_dir = file.path(temp_root, "data", "ocr"),
    output_dir = file.path(temp_root, "data", "output")
  )

  result_paths <- irs_ensure_dirs(test_paths)

  # Check that directories were created
  expect_true(dir.exists(test_paths$raw_xml_dir))
  expect_true(dir.exists(test_paths$raw_pdf_dir))
  expect_true(dir.exists(test_paths$index_dir))
  expect_true(dir.exists(test_paths$ocr_dir))
  expect_true(dir.exists(test_paths$output_dir))

  # Check return value
  expect_equal(result_paths, test_paths)
})

test_that("null-coalescing operator works", {
  `%||%` <- infoepi.NGOdata:::`%||%`

  expect_equal("a" %||% "b", "a")
  expect_equal(NULL %||% "b", "b")
  expect_equal("" %||% "b", "b")
  expect_equal(c("a", "b") %||% "c", c("a", "b"))
})