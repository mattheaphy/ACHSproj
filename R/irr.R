#' @importFrom S7 new_generic method `method<-` new_S3_class class_numeric S7_dispatch
NULL

#' Internal rate of return of a cashflow vector
#'
#' Finds the discount rate at which the present value of `x` is zero, using
#' [pv()] as the objective function.
#'
#' @param x A `cf_vec` or numeric vector of cashflow values.
#' @param interval Numeric vector of length 2 giving the lower and upper bounds
#'   of the search interval for the rate. Default `c(0, 0.25)`.
#' @param tol Convergence tolerance passed to [uniroot()]. Default `1e-16`.
#' @param maxiter Maximum number of iterations passed to [uniroot()]. Default `50`.
#' @param disc_freq Periodicity of the returned rate as number of periods per
#'   year: `12` (monthly), `6` (bimonthly), `4` (quarterly), `3` (trimonthly),
#'   `2` (semi-annual), or `1` (annual, default).
#' @param ... Additional arguments passed to methods. For numeric vectors,
#'   `freq` sets the cashflow periodicity as number of periods per year:
#'   `12` (monthly, default), `6` (bimonthly), `4` (quarterly), `3` (trimonthly),
#'   `2` (semi-annual), or `1` (annual).
#' @return A scalar double — the internal rate of return as an effective rate
#'   at `disc_freq` frequency (e.g. an annual effective rate when
#'   `disc_freq = 1L`).
#' @export
irr <- new_generic(
  "irr",
  "x",
  function(
    x,
    interval = c(0, 0.25),
    disc_freq = 1L,
    tol = 1e-16,
    maxiter = 50L,
    ...
  ) {
    S7_dispatch()
  }
)

method(irr, new_S3_class("cf_vec")) <- function(
  x,
  interval = c(0, 0.25),
  disc_freq = 1L,
  tol = 1e-16,
  maxiter = 50L
) {
  disc_freq <- validate_freq(disc_freq)
  freq <- attr(x, "freq")
  res <- uniroot(
    \(r) pv(x, r, disc_freq = freq),
    interval,
    extendInt = "yes",
    tol = tol,
    maxiter = maxiter
  )$root
  (1 + res)^(freq / disc_freq) - 1
}

method(irr, class_numeric) <- function(
  x,
  interval = c(0, 0.25),
  disc_freq = 1L,
  tol = 1e-16,
  maxiter = 50L,
  freq = 12L
) {
  irr(
    cf_vec(x, freq),
    interval = interval,
    disc_freq = disc_freq,
    tol = tol,
    maxiter = maxiter
  )
}
