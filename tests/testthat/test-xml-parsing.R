test_that("peek_filing_ein extracts EIN correctly", {
  # Create test XML file
  test_xml <- tempfile(fileext = ".xml")
  writeLines(
    c(
      '<?xml version="1.0" encoding="utf-8"?>',
      '<Return xmlns="http://www.irs.gov/efile" returnVersion="2023v5.0">',
      "<ReturnHeader>",
      "<TaxYr>2023</TaxYr>",
      "<ReturnTypeCd>990</ReturnTypeCd>",
      "<Filer>",
      "<EIN>123456789</EIN>",
      "<BusinessName><BusinessNameLine1Txt>Test Charity</BusinessNameLine1Txt></BusinessName>",
      "</Filer>",
      "</ReturnHeader>",
      "</Return>"
    ),
    test_xml
  )

  ein <- peek_filing_ein(test_xml)
  expect_equal(ein, "123456789")

  unlink(test_xml)
})

test_that("peek_filing_ein handles missing EIN", {
  # Create test XML file without EIN
  test_xml <- tempfile(fileext = ".xml")
  writeLines(
    c(
      '<?xml version="1.0" encoding="utf-8"?>',
      '<Return xmlns="http://www.irs.gov/efile">',
      "<ReturnHeader>",
      "<TaxYr>2023</TaxYr>",
      "</ReturnHeader>",
      "</Return>"
    ),
    test_xml
  )

  ein <- peek_filing_ein(test_xml)
  expect_null(ein)

  unlink(test_xml)
})

test_that("parse_990_xml processes complete filing", {
  # Create comprehensive test XML
  test_xml <- tempfile(fileext = ".xml")
  writeLines(
    c(
      '<?xml version="1.0" encoding="utf-8"?>',
      '<Return xmlns="http://www.irs.gov/efile" returnVersion="2023v5.0">',
      "<ReturnHeader>",
      "<TaxYr>2023</TaxYr>",
      "<ReturnTypeCd>990</ReturnTypeCd>",
      "<Filer>",
      "<EIN>123456789</EIN>",
      "<BusinessName><BusinessNameLine1Txt>Test Charity ABC</BusinessNameLine1Txt></BusinessName>",
      "<USAddress><CityNm>Boston</CityNm><StateAbbreviationCd>MA</StateAbbreviationCd></USAddress>",
      "</Filer>",
      "</ReturnHeader>",
      "<IRS990>",
      "<CYTotalRevenueAmt>50000</CYTotalRevenueAmt>",
      "<CYTotalExpensesAmt>40000</CYTotalExpensesAmt>",
      "<Form990PartVIISectionAGrp>",
      "<PersonNm>Jane Doe</PersonNm>",
      "<TitleTxt>Director</TitleTxt>",
      "<IndividualTrusteeOrDirectorInd>X</IndividualTrusteeOrDirectorInd>",
      "<ReportableCompFromOrgAmt>5000</ReportableCompFromOrgAmt>",
      "</Form990PartVIISectionAGrp>",
      "<Form990PartVIISectionAGrp>",
      "<PersonNm>John Smith</PersonNm>",
      "<TitleTxt>CEO</TitleTxt>",
      "<OfficerInd>X</OfficerInd>",
      "<ReportableCompFromOrgAmt>75000</ReportableCompFromOrgAmt>",
      "</Form990PartVIISectionAGrp>",
      "</IRS990>",
      "</Return>"
    ),
    test_xml
  )

  filing <- parse_990_xml(test_xml)

  # Test basic filing info
  expect_equal(filing$ein, "123456789")
  expect_equal(filing$tax_year, 2023L)
  expect_true(grepl("Test Charity", filing$organization_name))
  expect_equal(filing$city, "Boston")
  expect_equal(filing$state, "MA")

  # Test financial data
  expect_equal(filing$total_revenue, 50000)
  expect_equal(filing$total_expenses, 40000)

  # Test board members
  expect_length(filing$board_members, 2)
  expect_equal(filing$board_members[[1]]$name, "Jane Doe")
  expect_equal(filing$board_members[[1]]$title, "Director")
  expect_equal(filing$board_members[[1]]$reportable_comp_from_org, 5000)
  expect_equal(filing$board_members[[2]]$name, "John Smith")
  expect_equal(filing$board_members[[2]]$title, "CEO")
  expect_equal(filing$board_members[[2]]$reportable_comp_from_org, 75000)

  unlink(test_xml)
})

test_that("XML helper functions work correctly", {
  # Test irs_to_decimal
  expect_equal(irs_to_decimal("1,234.56"), 1234.56)
  expect_equal(irs_to_decimal("0"), 0)
  expect_true(is.na(irs_to_decimal("")))
  expect_true(is.na(irs_to_decimal(NULL)))
  # Suppress expected warning for invalid input
  expect_warning(result <- irs_to_decimal("invalid"))
  expect_true(is.na(result))

  # Test irs_to_int
  expect_equal(irs_to_int("1,234"), 1234L)
  expect_equal(irs_to_int("0"), 0L)
  expect_true(is.na(irs_to_int("")))
  expect_true(is.na(irs_to_int(NULL)))
  # Suppress expected warning for invalid input
  expect_warning(result <- irs_to_int("invalid"))
  expect_true(is.na(result))
})