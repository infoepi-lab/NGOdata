#include <R_ext/Rdynload.h>
#include <Rinternals.h>

SEXP infoepi_NGOdata_inflate_raw_(SEXP, SEXP);

static const R_CallMethodDef CallEntries[] = {
    {"C_infoepi_NGOdata_inflate_raw", (DL_FUNC) &infoepi_NGOdata_inflate_raw_, 2},
    {NULL, NULL, 0}};

void R_init_infoepi_NGOdata(DllInfo *dll) {
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
  R_forceSymbols(dll, TRUE);
}
