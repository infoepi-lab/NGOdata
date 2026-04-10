# Mirrors src/parse/xpath_registry.py — XPath variants per IRS schema version

BOARD_MEMBER_GROUPS <- c(
  ".//irs:Form990PartVIISectionAGrp",
  ".//irs:OfficerDirectorTrusteeEmplGrp",
  ".//irs:Form990PartVIISectionA",
  ".//irs:OfficerDirTrstKeyEmplInfoGrp/irs:OfficerDirTrstKeyEmplGrp",
  ".//Form990PartVIISectionAGrp",
  ".//OfficerDirectorTrusteeEmplGrp"
)

BOARD_MEMBER_FIELDS <- list(
  person_name = c(
    "irs:PersonNm", "irs:PersonName", "irs:Name/irs:PersonNameFirst",
    "PersonNm", "PersonName"
  ),
  business_name = c(
    "irs:BusinessName/irs:BusinessNameLine1Txt",
    "irs:BusinessName/irs:BusinessNameLine1",
    "BusinessName/BusinessNameLine1Txt"
  ),
  title = c("irs:TitleTxt", "irs:Title", "TitleTxt", "Title"),
  avg_hours = c(
    "irs:AverageHoursPerWeekRt", "irs:AverageHoursPerWeek",
    "irs:AvgHoursPerWkDevotedToPosRt", "AverageHoursPerWeekRt"
  ),
  avg_hours_related = c(
    "irs:AverageHoursPerWeekRltdOrgRt", "irs:AverageHrsPerWkDevToPositionRt",
    "AverageHoursPerWeekRltdOrgRt"
  ),
  trustee_or_director = c(
    "irs:IndividualTrusteeOrDirectorInd", "irs:IndividualTrusteeOrDirector",
    "IndividualTrusteeOrDirectorInd"
  ),
  officer = c("irs:OfficerInd", "irs:Officer", "OfficerInd"),
  key_employee = c("irs:KeyEmployeeInd", "irs:KeyEmployee", "KeyEmployeeInd"),
  highest_compensated = c(
    "irs:HighestCompensatedEmployeeInd", "irs:HighestCompensatedEmployee",
    "HighestCompensatedEmployeeInd"
  ),
  former = c(
    "irs:FormerOfcrDirectorTrusteeInd", "irs:Former",
    "FormerOfcrDirectorTrusteeInd"
  ),
  comp_from_org = c(
    "irs:ReportableCompFromOrgAmt", "irs:ReportableCompFromOrganization",
    "ReportableCompFromOrgAmt"
  ),
  comp_from_related = c(
    "irs:ReportableCompFromRltdOrgAmt", "irs:ReportableCompFromRelatedOrg",
    "ReportableCompFromRltdOrgAmt"
  ),
  other_comp = c(
    "irs:OtherCompensationAmt", "irs:OtherCompensation",
    "OtherCompensationAmt"
  )
)

FOREIGN_ACTIVITY_GROUPS <- c(
  ".//irs:AccountActivitiesOutsideUSGrp",
  ".//irs:AccountActivitiesOutsideUS",
  ".//irs:Form990ScheduleFPartI",
  ".//AccountActivitiesOutsideUSGrp"
)

FOREIGN_ACTIVITY_FIELDS <- list(
  region = c("irs:RegionTxt", "irs:Region", "RegionTxt"),
  num_offices = c("irs:OfficesCnt", "irs:NumberOfOffices", "OfficesCnt"),
  num_employees = c("irs:EmployeeCnt", "irs:NumberOfEmployees", "EmployeeCnt"),
  activities = c(
    "irs:TypeOfActivitiesConductedTxt", "irs:TypeOfActivitiesConducted",
    "TypeOfActivitiesConductedTxt"
  ),
  expenditures = c(
    "irs:TotalExpendituresAmt", "irs:TotalExpenditures", "TotalExpendituresAmt"
  )
)

FOREIGN_ORG_GRANT_GROUPS <- c(
  ".//irs:GrantsToOrgOutsideUSGrp",
  ".//irs:GrantsToOrganizationsOutsideUS",
  ".//irs:Form990ScheduleFPartII",
  ".//GrantsToOrgOutsideUSGrp"
)

FOREIGN_ORG_GRANT_FIELDS <- list(
  region = c("irs:RegionTxt", "irs:Region", "RegionTxt"),
  purpose = c("irs:PurposeOfGrantTxt", "irs:PurposeOfGrant", "PurposeOfGrantTxt"),
  cash_amount = c("irs:CashGrantAmt", "irs:CashGrant", "CashGrantAmt"),
  non_cash_amount = c(
    "irs:NonCashAssistanceAmt", "irs:NonCashAssistance", "NonCashAssistanceAmt"
  ),
  manner_of_disbursement = c(
    "irs:MannerOfCashDisbursementTxt", "irs:MannerOfCashDisbursement",
    "MannerOfCashDisbursementTxt"
  ),
  valuation_method = c(
    "irs:ValuationMethodUsedDesc", "irs:ValuationMethodUsed",
    "ValuationMethodUsedDesc"
  ),
  recipient_count = c(
    "irs:RecipientCnt", "irs:NumberOfRecipients", "RecipientCnt"
  ),
  recipient_name = c(
    "irs:RecipientBusinessName/irs:BusinessNameLine1Txt",
    "irs:RecipientNameBusiness/irs:BusinessNameLine1",
    "RecipientBusinessName/BusinessNameLine1Txt"
  ),
  recipient_address = c(
    "irs:RecipientUSAddress/irs:AddressLine1Txt",
    "irs:RecipientForeignAddress/irs:AddressLine1Txt",
    "irs:AddressLine1",
    "irs:RecipientForeignAddress/irs:AddressLine1"
  ),
  recipient_country = c(
    "irs:RecipientForeignAddress/irs:CountryCd",
    "irs:RecipientUSAddress/irs:CountryCd",
    "irs:CountryCd",
    "RecipientForeignAddress/CountryCd"
  ),
  irs_section = c("irs:IRCSectionDesc", "irs:IRCSection", "IRCSectionDesc")
)

FOREIGN_INDIVIDUAL_GRANT_GROUPS <- c(
  ".//irs:ForeignIndividualsGrantsGrp",
  ".//irs:GrantsToIndividualsOutsideUS",
  ".//irs:Form990ScheduleFPartIII",
  ".//ForeignIndividualsGrantsGrp"
)

FOREIGN_INDIVIDUAL_GRANT_FIELDS <- list(
  activity_type = c("irs:ActivityTypeTxt", "irs:TypeOfAssistance", "ActivityTypeTxt"),
  region = c("irs:RegionTxt", "irs:Region", "RegionTxt"),
  recipient_count = c("irs:RecipientCnt", "irs:NumberOfRecipients", "RecipientCnt"),
  cash_amount = c("irs:CashGrantAmt", "irs:AmountOfCashGrant", "CashGrantAmt"),
  manner_of_disbursement = c(
    "irs:MannerOfCashDisbursementTxt", "irs:MannerOfCashDisbursement",
    "MannerOfCashDisbursementTxt"
  ),
  non_cash_amount = c(
    "irs:NonCashAssistanceAmt", "irs:AmountOfNonCashAssistance",
    "NonCashAssistanceAmt"
  ),
  valuation_method = c(
    "irs:ValuationMethodUsedDesc", "irs:ValuationMethodUsed",
    "ValuationMethodUsedDesc"
  ),
  non_cash_description = c(
    "irs:NonCashAssistanceDesc", "irs:DescriptionOfNonCashAssistance",
    "NonCashAssistanceDesc"
  )
)

HEADER_FIELDS <- list(
  ein = c(
    ".//irs:Filer/irs:EIN",
    ".//irs:ReturnHeader/irs:Filer/irs:EIN",
    ".//Filer/EIN",
    ".//Return/ReturnHeader/Filer/EIN"
  ),
  org_name = c(
    ".//irs:Filer/irs:BusinessName/irs:BusinessNameLine1Txt",
    ".//irs:Filer/irs:Name/irs:BusinessNameLine1",
    ".//irs:Filer/irs:BusinessName/irs:BusinessNameLine1",
    ".//Filer/BusinessName/BusinessNameLine1Txt"
  ),
  tax_year = c(
    ".//irs:ReturnHeader/irs:TaxYr",
    ".//irs:ReturnHeader/irs:TaxYear",
    ".//irs:TaxYr",
    ".//ReturnHeader/TaxYr"
  ),
  form_type = c(
    ".//irs:ReturnHeader/irs:ReturnTypeCd",
    ".//irs:ReturnHeader/irs:ReturnType",
    ".//ReturnHeader/ReturnTypeCd"
  ),
  state = c(
    ".//irs:Filer/irs:USAddress/irs:StateAbbreviationCd",
    ".//irs:Filer/irs:USAddress/irs:State",
    ".//Filer/USAddress/StateAbbreviationCd"
  ),
  city = c(
    ".//irs:Filer/irs:USAddress/irs:CityNm",
    ".//irs:Filer/irs:USAddress/irs:City",
    ".//Filer/USAddress/CityNm"
  ),
  total_revenue = c(
    ".//irs:IRS990/irs:CYTotalRevenueAmt",
    ".//irs:IRS990/irs:TotalRevenueCurrentYear",
    ".//IRS990/CYTotalRevenueAmt"
  ),
  total_expenses = c(
    ".//irs:IRS990/irs:CYTotalExpensesAmt",
    ".//irs:IRS990/irs:TotalExpensesCurrentYear",
    ".//IRS990/CYTotalExpensesAmt"
  ),
  total_assets = c(
    ".//irs:IRS990/irs:TotalAssetsEOYAmt",
    ".//irs:IRS990/irs:TotalAssetsEndOfYear",
    ".//IRS990/TotalAssetsEOYAmt"
  )
)
