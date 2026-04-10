# Run: Rscript R/infoepi.NGOdata/tests/smoke_parse.R (from repo root)
tf <- tempfile(fileext = ".xml")
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
    "<ReportableCompFromOrgAmt>0</ReportableCompFromOrgAmt>",
    "</Form990PartVIISectionAGrp>",
    "</IRS990>",
    "</Return>"
  ),
  tf
)
library(infoepi.NGOdata)
stopifnot(infoepi.NGOdata::peek_filing_ein(tf) == "123456789")
f <- infoepi.NGOdata::parse_990_xml(tf)
stopifnot(f$ein == "123456789")
stopifnot(grepl("Test Charity", f$organization_name))
stopifnot(f$tax_year == 2023L)
stopifnot(length(f$board_members) >= 1L)
stopifnot(f$board_members[[1]]$name == "Jane Doe")
bm <- infoepi.NGOdata::board_members_to_tibble(f$board_members)
stopifnot(nrow(bm) == 1L)
message("parse_smoke: OK")
unlink(tf)
