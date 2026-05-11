#' @importFrom vctrs vec_ptype2 vec_cast vec_ptype_abbr vec_math vec_arith vec_math_base vec_arith_base
NULL

new_cf_vec <- function(x = double(), freq = 12L) {
  vctrs::new_vctr(x, freq = freq, class = "cf_vec")
}

validate_freq <- function(freq, call = rlang::caller_env()) {
  arg <- rlang::caller_arg(freq)
  freq <- as.integer(freq)
  allowed <- c(12L, 6L, 4L, 3L, 2L, 1L)
  if (!freq %in% allowed) {
    cli::cli_abort(
      "{.arg {arg}} must be one of {.val {allowed}}, not {.val {freq}}.",
      call = call
    )
  }
  freq
}

#' Create a cashflow vector
#'
#' @param x A numeric vector of cashflow values.
#' @param freq Periodicity of the cashflows as number of periods per year:
#'   `12` (monthly, default), `6` (bimonthly), `4` (quarterly), `3` (trimonthly),
#'   `2` (semi-annual), or `1` (annual).
#' @return A `cf_vec` object.
#' @export
cf_vec <- function(x = double(), freq = 12L) {
  x <- as.double(x)
  freq <- validate_freq(freq)
  new_cf_vec(x, freq)
}

# vctrs protocol ---------------------------------------------------------------

#' @export
format.cf_vec <- function(x, ...) {
  format(vctrs::vec_data(x), ...)
}

#' @export
vec_ptype_abbr.cf_vec <- function(x, ...) {
  abbr <- switch(
    as.character(attr(x, "freq")),
    "12" = "mo",
    "6" = "bmo",
    "4" = "qtr",
    "3" = "tmo",
    "2" = "sa",
    "1" = "yr"
  )
  paste0("cf<", abbr, ">")
}

#' @export
vec_ptype2.cf_vec.cf_vec <- function(x, y, ...) {
  if (!identical(attr(x, "freq"), attr(y, "freq"))) {
    cli::cli_abort(
      "Can't combine {.cls cf_vec} vectors with different \\
      {.field freq} values \\
      ({.val {attr(x, 'freq')}} vs {.val {attr(y, 'freq')}})."
    )
  }
  new_cf_vec(freq = attr(x, "freq"))
}

#' @export
vec_cast.cf_vec.cf_vec <- function(x, to, ...) x

#' @export
vec_ptype2.cf_vec.double <- function(x, y, ...) {
  new_cf_vec(freq = attr(x, "freq"))
}

#' @export
vec_ptype2.double.cf_vec <- function(x, y, ...) {
  new_cf_vec(freq = attr(y, "freq"))
}

#' @export
vec_cast.cf_vec.double <- function(x, to, ...) new_cf_vec(x, attr(to, "freq"))

#' @export
vec_cast.double.cf_vec <- function(x, to, ...) vctrs::vec_data(x)

#' @export
vec_math.cf_vec <- function(.fn, .x, ...) {
  new_cf_vec(vctrs::vec_math_base(.fn, .x, ...), attr(.x, "freq"))
}

#' @export
vec_arith.cf_vec <- function(op, x, y, ...) {
  if (inherits(y, "MISSING")) {
    return(new_cf_vec(do.call(op, list(vctrs::vec_data(x))), attr(x, "freq")))
  }
  if (inherits(y, "cf_vec") && !identical(attr(x, "freq"), attr(y, "freq"))) {
    cli::cli_abort(
      "Can't combine {.cls cf_vec} vectors with different \\
      {.field freq} values \\
      ({.val {attr(x, 'freq')}} vs {.val {attr(y, 'freq')}})."
    )
  }
  new_cf_vec(vctrs::vec_arith_base(op, x, y, ...), attr(x, "freq"))
}
