irs_xml_ns_map <- function(root) {
  if (!inherits(root, "xml_document") && !inherits(root, "xml_node")) {
    stop("root must be an xml_document or xml_node object", call. = FALSE)
  }

  u <- tryCatch(
    xml2::xml_ns(root),
    error = function(e) {
      stop("Failed to extract XML namespaces: ", e$message, call. = FALSE)
    }
  )

  if (!length(u)) return(c(irs = "http://www.irs.gov/efile"))
  nm <- names(u)
  href <- as.character(u)
  hit <- grep("irs\\.gov", href, ignore.case = TRUE)[1]
  if (!is.na(hit)) {
    return(c(irs = href[hit]))
  }
  c(irs = href[1])
}

xml_find_first_try <- function(node, xpaths, ns) {
  if (!inherits(node, "xml_node") && !inherits(node, "xml_document")) {
    stop("node must be an xml_node or xml_document object", call. = FALSE)
  }
  if (!is.character(xpaths) || length(xpaths) == 0) {
    stop("xpaths must be a non-empty character vector", call. = FALSE)
  }
  if (!is.character(ns) && !is.null(ns)) {
    stop("ns must be a character vector or NULL", call. = FALSE)
  }

  for (xp in xpaths) {
    el <- tryCatch(
      xml2::xml_find_first(node, xp, ns = ns),
      error = function(e) {
        warning("XPath query failed: ", xp, " - ", e$message, call. = FALSE)
        NULL
      }
    )
    if (!is.null(el) && !inherits(el, "xml_missing")) {
      txt <- xml2::xml_text(el)
      if (length(txt) && nzchar(stringr::str_trim(txt))) {
        return(stringr::str_trim(txt))
      }
    }
  }
  NULL
}

xml_find_all_try <- function(node, xpaths, ns) {
  if (!inherits(node, "xml_node") && !inherits(node, "xml_document")) {
    stop("node must be an xml_node or xml_document object", call. = FALSE)
  }
  if (!is.character(xpaths) || length(xpaths) == 0) {
    stop("xpaths must be a non-empty character vector", call. = FALSE)
  }
  if (!is.character(ns) && !is.null(ns)) {
    stop("ns must be a character vector or NULL", call. = FALSE)
  }

  for (xp in xpaths) {
    els <- tryCatch(
      xml2::xml_find_all(node, xp, ns = ns),
      error = function(e) {
        warning("XPath query failed: ", xp, " - ", e$message, call. = FALSE)
        NULL
      }
    )
    if (!is.null(els) && length(els)) return(els)
  }
  xml2::xml_find_all(node, ".//*[false()]", ns = ns)
}

irs_to_decimal <- function(s) {
  if (is.null(s)) return(NA_real_)
  if (!is.character(s) && !is.numeric(s)) {
    warning("Input should be character or numeric, got: ", class(s)[1], call. = FALSE)
    return(NA_real_)
  }
  if (is.character(s) && (!length(s) || !nzchar(s))) return(NA_real_)

  s_clean <- gsub(",", "", as.character(s), fixed = TRUE)
  x <- suppressWarnings(as.numeric(s_clean))
  if (is.na(x)) {
    warning("Could not convert to numeric: '", s, "'", call. = FALSE)
    NA_real_
  } else {
    x
  }
}

irs_to_int <- function(s) {
  if (is.null(s)) return(NA_integer_)
  if (!is.character(s) && !is.numeric(s)) {
    warning("Input should be character or numeric, got: ", class(s)[1], call. = FALSE)
    return(NA_integer_)
  }
  if (is.character(s) && (!length(s) || !nzchar(s))) return(NA_integer_)

  s_clean <- gsub(",", "", as.character(s), fixed = TRUE)
  x <- suppressWarnings(as.integer(s_clean))
  if (is.na(x)) {
    warning("Could not convert to integer: '", s, "'", call. = FALSE)
    NA_integer_
  } else {
    x
  }
}

irs_to_float <- function(s) {
  if (is.null(s) || !nzchar(s)) return(NA_real_)
  s <- gsub(",", "", s, fixed = TRUE)
  suppressWarnings(as.numeric(s))
}

irs_is_true <- function(s) {
  if (is.null(s) || !nzchar(s)) return(FALSE)
  toupper(stringr::str_trim(s)) %in% c("X", "1", "TRUE", "YES")
}

irs_int0 <- function(s) {
  x <- irs_to_int(s)
  if (length(x) != 1L || is.na(x)) 0L else x
}

infoepi_NGOdata_inflate_raw <- function(raw_vec, out_capacity) {
  if (!is.raw(raw_vec)) {
    stop("raw_vec must be a raw vector", call. = FALSE)
  }
  if (length(raw_vec) == 0) {
    stop("raw_vec cannot be empty", call. = FALSE)
  }
  if (!is.numeric(out_capacity) || length(out_capacity) != 1 || is.na(out_capacity) || out_capacity < 1) {
    stop("out_capacity must be a positive numeric value", call. = FALSE)
  }

  # Call the registered native symbol directly. `R_forceSymbols(dll, TRUE)` in
  # src/irs990_init.c disables lookup by string name, so we reference the
  # symbol object exposed by `useDynLib(.registration = TRUE)` in NAMESPACE.
  tryCatch(
    .Call(C_infoepi_NGOdata_inflate_raw, raw_vec, as.double(out_capacity)),
    error = function(e) {
      stop("Decompression failed: ", e$message, call. = FALSE)
    }
  )
}
