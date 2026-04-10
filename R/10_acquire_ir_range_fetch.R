# Mirrors src/acquire/irs_range_fetch.py — HTTP Range into IRS TEOS ZIPs

EOCD_SIG <- as.raw(c(0x50, 0x4b, 0x05, 0x06))
CD_SIG <- as.raw(c(0x50, 0x4b, 0x01, 0x02))
LOCAL_SIG <- as.raw(c(0x50, 0x4b, 0x03, 0x04))
EOCD64_LOC_SIG <- as.raw(c(0x50, 0x4b, 0x06, 0x07))
EOCD64_SIG <- as.raw(c(0x50, 0x4b, 0x06, 0x06))

le_u16 <- function(b, i) {
  as.numeric(b[i]) + as.numeric(b[i + 1L]) * 256
}

le_u32 <- function(b, i) {
  sum(as.numeric(b[i:(i + 3L)]) * 256^(0:3))
}

le_u64 <- function(b, i) {
  lo <- le_u32(b, i)
  hi <- le_u32(b, i + 4L)
  hi * 2^32 + lo
}

raw_find_last <- function(haystack, pat) {
  nh <- length(haystack)
  np <- length(pat)
  if (nh < np) return(0L)
  for (st in seq.int(nh - np + 1L, 1L)) {
    ok <- TRUE
    for (j in seq_len(np)) {
      if (haystack[st + j - 1L] != pat[j]) {
        ok <- FALSE
        break
      }
    }
    if (ok) return(as.integer(st))
  }
  0L
}

irs_http_range <- function(url, start, end, retries = 5L) {
  want <- end - start + 1L
  last_err <- NULL
  for (attempt in seq_len(retries)) {
    out <- tryCatch(
      {
        r <- httr2::request(url) |>
          httr2::req_headers(Range = sprintf("bytes=%d-%d", start, end)) |>
          httr2::req_options(timeout = 120)
        resp <- httr2::req_perform(r)
        st <- httr2::resp_status(resp)
        if (!st %in% c(200L, 206L)) {
          stop("HTTP ", st)
        }
        bod <- httr2::resp_body_raw(resp)
        if (st == 206L && length(bod) < want) {
          stop("incomplete range")
        }
        bod
      },
      error = function(e) e
    )
    if (!inherits(out, "error")) return(out)
    last_err <- out
    if (attempt < retries) Sys.sleep(min(8, 2^attempt))
  }
  stop(conditionMessage(last_err))
}

irs_http_head_size <- function(url, retries = 4L) {
  last_err <- NULL
  for (attempt in seq_len(retries)) {
    out <- tryCatch(
      {
        r <- httr2::request(url) |>
          httr2::req_method("HEAD") |>
          httr2::req_options(timeout = 30)
        resp <- httr2::req_perform(r)
        if (httr2::resp_status(resp) != 200L) stop("HEAD failed")
        cl <- httr2::resp_header(resp, "content-length")
        if (is.na(cl)) stop("no content-length")
        as.numeric(cl)
      },
      error = function(e) e
    )
    if (!inherits(out, "error")) return(out)
    last_err <- out
    if (attempt < retries) Sys.sleep(min(6, 2^attempt))
  }
  stop(conditionMessage(last_err))
}

zip_find_eocd <- function(zip_url, zip_size) {
  tail_size <- as.integer(min(65536L, zip_size))
  start <- zip_size - tail_size
  tail <- irs_http_range(zip_url, start, zip_size - 1L)
  pos <- raw_find_last(tail, EOCD_SIG)
  if (!pos) stop("EOCD not found")
  eocd <- tail[pos:length(tail)]
  if (length(eocd) < 22L) stop("EOCD too short")
  cd_size <- le_u32(eocd, 13L)
  cd_offset <- le_u32(eocd, 17L)
  cd_records_total <- le_u16(eocd, 11L)
  if (cd_offset >= 0xFFFFFFFF || cd_records_total == 0xFFFFL) {
    return(zip_find_eocd64(zip_url, tail, pos))
  }
  list(cd_offset = cd_offset, cd_size = cd_size, total_entries = cd_records_total)
}

zip_find_eocd64 <- function(zip_url, tail, eocd_pos) {
  loc_pos <- raw_find_last(tail[seq_len(max(1L, eocd_pos - 1L))], EOCD64_LOC_SIG)
  if (!loc_pos) stop("ZIP64 locator not found")
  eocd64_off <- le_u64(tail, loc_pos + 8L)
  dat <- irs_http_range(zip_url, eocd64_off, eocd64_off + 63L)
  if (le_u32(dat, 1L) != le_u32(EOCD64_SIG, 1L)) stop("ZIP64 EOCD sig mismatch")
  cd_records_total <- le_u64(dat, 33L)
  cd_size <- le_u64(dat, 41L)
  cd_offset <- le_u64(dat, 49L)
  list(cd_offset = cd_offset, cd_size = cd_size, total_entries = cd_records_total)
}

zip_parse_central_directory <- function(cd_data) {
  entries <- list()
  offset <- 1L
  n <- length(cd_data)
  while (offset <= n - 4L) {
    if (le_u32(cd_data, offset) != le_u32(CD_SIG, 1L)) break
    compression <- le_u16(cd_data, offset + 10L)
    crc32 <- le_u32(cd_data, offset + 16L)
    compressed_size <- le_u32(cd_data, offset + 20L)
    uncompressed_size <- le_u32(cd_data, offset + 24L)
    name_len <- le_u16(cd_data, offset + 28L)
    extra_len <- le_u16(cd_data, offset + 30L)
    comment_len <- le_u16(cd_data, offset + 32L)
    local_offset <- le_u32(cd_data, offset + 42L)
    name_start <- offset + 46L
    filename <- rawToChar(cd_data[name_start:(name_start + name_len - 1L)], multiple = FALSE)
    extra_start <- name_start + name_len
    extra_data <- cd_data[extra_start:(extra_start + extra_len - 1L)]

    if (compressed_size == 0xFFFFFFFF || uncompressed_size == 0xFFFFFFFF ||
      local_offset == 0xFFFFFFFF) {
      epos <- 1L
      elen <- length(extra_data)
      while (epos <= elen - 4L) {
        eid <- le_u16(extra_data, epos)
        esize <- le_u16(extra_data, epos + 2L)
        if (eid == 1L) {
          vpos <- epos + 4L
          if (uncompressed_size == 0xFFFFFFFF) {
            uncompressed_size <- le_u64(extra_data, vpos)
            vpos <- vpos + 8L
          }
          if (compressed_size == 0xFFFFFFFF) {
            compressed_size <- le_u64(extra_data, vpos)
            vpos <- vpos + 8L
          }
          if (local_offset == 0xFFFFFFFF) {
            local_offset <- le_u64(extra_data, vpos)
          }
          break
        }
        epos <- epos + 4L + esize
      }
    }

    entries[[length(entries) + 1L]] <- list(
      filename = filename,
      compressed_size = compressed_size,
      uncompressed_size = uncompressed_size,
      local_header_offset = local_offset,
      compression_method = compression
    )
    offset <- name_start + name_len + extra_len + comment_len
  }
  entries
}

zip_extract_entry <- function(zip_url, entry) {
  off <- as.numeric(entry$local_header_offset)
  hdr <- irs_http_range(zip_url, off, off + 29L)
  if (le_u32(hdr, 1L) != le_u32(LOCAL_SIG, 1L)) stop("bad local header")
  name_len <- le_u16(hdr, 27L)
  extra_len <- le_u16(hdr, 29L)
  data_off <- off + 30 + name_len + extra_len
  comp <- as.numeric(entry$compressed_size)
  data_end <- data_off + comp - 1
  compressed_data <- irs_http_range(zip_url, data_off, data_end)

  m <- entry$compression_method
  if (m == 0L) {
    return(compressed_data)
  }
  if (m == 8L) {
    u <- as.numeric(entry$uncompressed_size) + 256
    return(infoepi_NGOdata_inflate_raw(compressed_data, u))
  }
  if (m == 9L) {
    stop(
      "ZIP uses Deflate64 (method 9). Use the Python pipeline or install a full ZIP downloader."
    )
  }
  stop("unsupported compression method: ", m)
}

zip_fetch_named_members <- function(zip_url, target_filenames) {
  targets <- target_filenames
  if (!is.character(targets)) targets <- as.character(targets)
  want <- unique(targets)
  zip_size <- irs_http_head_size(zip_url)
  eocd <- zip_find_eocd(zip_url, zip_size)
  cd <- irs_http_range(
    zip_url,
    eocd$cd_offset,
    eocd$cd_offset + eocd$cd_size - 1
  )
  entries <- zip_parse_central_directory(cd)
  results <- list()
  bare_want <- basename(want)
  names(bare_want) <- want

  for (ent in entries) {
    bare <- basename(ent$filename)
    if (bare %in% bare_want) {
      results[[bare]] <- zip_extract_entry(zip_url, ent)
    }
  }
  results
}

irs_index_csv_valid <- function(path) {
  if (!file.exists(path) || file.info(path)$size < 10000) return(FALSE)
  h <- utils::read.csv(path, nrows = 2L, check.names = FALSE, stringsAsFactors = FALSE)
  if (!"EIN" %in% names(h)) return(FALSE)
  if (!nrow(h)) return(FALSE)
  TRUE
}

#' Download IRS year index CSV (cached under `paths$index_dir`)
#' @param year Tax index year
#' @param paths From [irs_project_paths()]
#' @export
irs_download_index <- function(year, paths = irs_project_paths()) {
  dir.create(paths$index_dir, recursive = TRUE, showWarnings = FALSE)
  fp <- file.path(paths$index_dir, sprintf("index_%d.csv", year))
  if (irs_index_csv_valid(fp)) return(fp)
  unlink(fp)
  url <- sprintf("%s/%d/index_%d.csv", IRS_XML_BASE, year, year)
  tmp <- paste0(fp, ".part")
  curl <- Sys.which("curl")
  if (nzchar(curl)) {
    for (att in 1:3) {
      unlink(tmp)
      status <- system2(
        curl,
        c(
          "-L", "--http1.1", "--retry", "10", "--retry-delay", "4",
          "--retry-all-errors", "--max-time", "900", "-o", tmp, url
        ),
        stdout = FALSE, stderr = FALSE
      )
      if (status == 0 && irs_index_csv_valid(tmp)) {
        file.rename(tmp, fp)
        return(fp)
      }
    }
    unlink(tmp)
  }
  # httr2 often succeeds when utils::download.file / RStudio SSL fails on IRS
  unlink(tmp)
  ok_h2 <- tryCatch(
    {
      resp <- httr2::request(url) |>
        httr2::req_headers(
          "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) IRS990-R/1.0"
        ) |>
        httr2::req_options(timeout = 920) |>
        httr2::req_perform()
      if (httr2::resp_status(resp) != 200L) {
        stop("HTTP ", httr2::resp_status(resp))
      }
      b <- httr2::resp_body_raw(resp)
      writeBin(b, tmp)
      TRUE
    },
    error = function(e) {
      unlink(tmp)
      FALSE
    }
  )
  if (isTRUE(ok_h2) && irs_index_csv_valid(tmp)) {
    file.rename(tmp, fp)
    return(fp)
  }
  if (file.exists(tmp)) {
    unlink(tmp)
  }
  dl <- tryCatch(
    utils::download.file(url, tmp, mode = "wb", quiet = TRUE),
    error = function(e) 1L
  )
  if (dl == 0L && irs_index_csv_valid(tmp)) {
    file.rename(tmp, fp)
    return(fp)
  }
  unlink(tmp)
  NA_character_
}

irs_index_df_for_year <- function(year, paths, cache_env) {
  ck <- paste0("df_", year)
  if (exists(ck, envir = cache_env, inherits = FALSE)) {
    return(get(ck, envir = cache_env))
  }
  fp <- irs_download_index(year, paths)
  if (is.na(fp)) {
    assign(ck, NULL, envir = cache_env)
    return(NULL)
  }
  df <- readr::read_csv(fp, show_col_types = FALSE, progress = FALSE)
  df$ein_norm <- gsub("-", "", as.character(df$EIN), fixed = TRUE)
  assign(ck, df, envir = cache_env)
  df
}

#' Search index rows for EINs in a year
#' @param year Tax year to search in
#' @param eins Character vector of EINs to search for
#' @param paths Named list of directory paths from `irs_project_paths()`
#' @param cache_env Environment for caching index data (optional)
#' @export
irs_search_index <- function(year, eins, paths = irs_project_paths(), cache_env = NULL) {
  if (is.null(cache_env)) cache_env <- new.env(parent = emptyenv())
  df <- irs_index_df_for_year(year, paths, cache_env)
  if (is.null(df) || !nrow(df)) return(list())
  es <- unique(gsub("-", "", eins, fixed = TRUE))
  sub <- df[df$ein_norm %in% es, , drop = FALSE]
  if (!nrow(sub)) return(list())
  lapply(seq_len(nrow(sub)), function(i) as.list(sub[i, , drop = FALSE]))
}

irs_discover_segments <- function(year) {
  segs <- character()
  for (num in 1:12) {
    for (letter in c("A", "B", "C", "D")) {
      seg <- sprintf("%02d%s", num, letter)
      url <- sprintf("%s/%d/%d_TEOS_XML_%s.zip", IRS_XML_BASE, year, year, seg)
      st <- tryCatch(
        {
          r <- httr2::request(url) |>
            httr2::req_method("HEAD") |>
            httr2::req_options(timeout = 10)
          httr2::resp_status(httr2::req_perform(r))
        },
        error = function(e) 0L
      )
      if (st == 200L) segs <- c(segs, seg)
    }
  }
  unique(segs)
}

#' Fetch XML files for EINs for one index year (Range into TEOS ZIPs)
#' @param year Tax year to fetch
#' @param eins Character vector of EINs to fetch
#' @param paths Named list of directory paths from `irs_project_paths()`
#' @param cache_env Environment for caching index data (optional)
#' @export
irs_fetch_eins_for_year <- function(
    year,
    eins,
    paths = irs_project_paths(),
    cache_env = NULL
) {
  if (is.null(cache_env)) cache_env <- new.env(parent = emptyenv())
  irs_ensure_dirs(paths)
  out_dir <- paths$raw_xml_dir
  matches <- irs_search_index(year, eins, paths, cache_env)
  if (!length(matches)) return(character())

  targets <- list()
  oid_to_segment <- list()
  for (m in matches) {
    rt <- as.character(m$RETURN_TYPE %||% "")
    if (length(rt) != 1L || is.na(rt)) rt <- ""
    if (rt %in% c("990N", "990T")) next
    raw_oid <- as.character(m$OBJECT_ID %||% "")
    if (length(raw_oid) != 1L || is.na(raw_oid) || !nzchar(raw_oid)) next
    if (grepl(",", raw_oid, fixed = TRUE)) {
      parts <- strsplit(raw_oid, ",", fixed = TRUE)[[1L]]
      oid <- trimws(parts[[1L]])
      segfull <- trimws(parts[[2L]])
      fn <- sprintf("%s_public.xml", oid)
      oid_to_segment[[fn]] <- segfull
    } else {
      oid <- trimws(raw_oid)
      fn <- sprintf("%s_public.xml", oid)
    }
    targets[[fn]] <- m
  }
  if (!length(targets)) return(character())

  needed <- character()
  existing <- character()
  for (fn in names(targets)) {
    p <- file.path(out_dir, fn)
    if (file.exists(p)) existing <- c(existing, p) else needed <- c(needed, fn)
  }

  extracted <- existing
  if (!length(needed)) return(extracted)

  by_segment <- list()
  unknown <- character()
  for (fn in needed) {
    if (!is.null(oid_to_segment[[fn]])) {
      segfull <- oid_to_segment[[fn]]
      seg_code <- if (grepl("_", segfull, fixed = TRUE)) {
        sub("^.*_", "", segfull)
      } else {
        segfull
      }
      by_segment[[seg_code]] <- c(by_segment[[seg_code]], fn)
    } else {
      unknown <- c(unknown, fn)
    }
  }

  still_needed <- needed
  for (seg_code in names(by_segment)) {
    fnames <- unique(by_segment[[seg_code]])
    fnames <- intersect(fnames, still_needed)
    if (!length(fnames)) next
    zip_url <- sprintf("%s/%d/%d_TEOS_XML_%s.zip", IRS_XML_BASE, year, year, seg_code)
    res <- tryCatch(
      zip_fetch_named_members(zip_url, fnames),
      error = function(e) {
        message(conditionMessage(e))
        list()
      }
    )
    for (nm in names(res)) {
      p <- file.path(out_dir, nm)
      writeBin(res[[nm]], p)
      extracted <- c(extracted, p)
      still_needed <- setdiff(still_needed, nm)
      unknown <- setdiff(unknown, nm)
    }
  }

  unk <- intersect(unknown, still_needed)
  if (length(unk)) {
    for (seg in irs_discover_segments(year)) {
      if (!length(still_needed)) break
      zip_url <- sprintf("%s/%d/%d_TEOS_XML_%s.zip", IRS_XML_BASE, year, year, seg)
      res <- tryCatch(
        zip_fetch_named_members(zip_url, still_needed),
        error = function(e) list()
      )
      for (nm in names(res)) {
        p <- file.path(out_dir, nm)
        writeBin(res[[nm]], p)
        extracted <- c(extracted, p)
        still_needed <- setdiff(still_needed, nm)
      }
    }
  }

  unique(extracted)
}

#' Multi-year fetch (mirrors `IRSSmartDownloader.fetch_all`)
#' @param eins Character vector of EINs to fetch
#' @param years Integer vector of tax years to search (default: 2017:2025)
#' @param paths Named list of directory paths from `irs_project_paths()`
#' @export
irs_smart_fetch <- function(
    eins,
    years = 2017:2025,
    paths = irs_project_paths()
) {
  cache_env <- new.env(parent = emptyenv())
  allp <- character()
  for (y in years) {
    allp <- c(allp, irs_fetch_eins_for_year(y, eins, paths, cache_env))
  }
  unique(allp)
}
