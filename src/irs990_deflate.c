#include <R.h>
#include <Rinternals.h>
#include <zlib.h>
#include <string.h>

/* Raw deflate (ZIP method 8) — windowBits = -MAX_WBITS */

SEXP infoepi_NGOdata_inflate_raw_(SEXP r_bytes, SEXP r_outcap) {
  if (TYPEOF(r_bytes) != RAWSXP)
    error("raw vector expected");
  R_xlen_t inlen = XLENGTH(r_bytes);
  const Bytef *in = (const Bytef *) RAW(r_bytes);

  double cap_d = asReal(r_outcap);
  if (!R_FINITE(cap_d) || cap_d < 256.0)
    error("invalid output capacity");
  R_xlen_t out_cap = (R_xlen_t) cap_d;

  SEXP out = PROTECT(allocVector(RAWSXP, out_cap));
  z_stream strm;
  memset(&strm, 0, sizeof(strm));
  strm.next_in = (Bytef *) in;
  strm.avail_in = (uInt) inlen;
  if ((R_xlen_t) strm.avail_in != inlen)
    error("compressed input too large for this build");

  strm.next_out = RAW(out);
  strm.avail_out = (uInt) out_cap;
  if ((R_xlen_t) strm.avail_out != out_cap)
    error("output capacity too large for zlib uInt");

  int ret = inflateInit2(&strm, -MAX_WBITS);
  if (ret != Z_OK) {
    UNPROTECT(1);
    error("inflateInit2 failed: %d", ret);
  }

  ret = inflate(&strm, Z_FINISH);
  if (ret != Z_STREAM_END) {
    inflateEnd(&strm);
    UNPROTECT(1);
    error("inflate failed (try larger buffer; code %d)", ret);
  }
  inflateEnd(&strm);

  R_xlen_t total = (R_xlen_t) strm.total_out;
  if (total == out_cap) {
    UNPROTECT(1);
    return out;
  }
  SEXP ans = PROTECT(allocVector(RAWSXP, total));
  memcpy(RAW(ans), RAW(out), total);
  UNPROTECT(2);
  return ans;
}
