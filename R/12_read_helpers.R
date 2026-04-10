#' XPath variants for Schedule F Part I "type of activities conducted"
#' (same list as `FOREIGN_ACTIVITY_FIELDS$activities`).
#' @export
irs_xpaths_type_of_activities_conducted <- function() {
  FOREIGN_ACTIVITY_FIELDS$activities
}

#' Read "type of activities conducted" for each Schedule F Part I row in a 990 XML
#'
#' Uses the same XPaths as the full parser (`parse_990_xml()` → foreign activities).
#'
#' @param xml_path Path to a Form 990 XML file.
#' @return Character vector, one string per matching group (use `NA_character_` if blank).
#' @export
irs_read_schedule_f_part1_activities <- function(xml_path) {
  doc <- xml2::read_xml(xml_path)
  root <- xml2::xml_root(doc)
  ns <- irs_xml_ns_map(root)
  grps <- xml_find_all_try(root, FOREIGN_ACTIVITY_GROUPS, ns)
  if (!length(grps)) {
    return(character())
  }
  vapply(grps, function(grp) {
    t <- xml_find_first_try(grp, FOREIGN_ACTIVITY_FIELDS$activities, ns)
    if (is.null(t) || !nzchar(t)) {
      NA_character_
    } else {
      t
    }
  }, character(1L))
}
