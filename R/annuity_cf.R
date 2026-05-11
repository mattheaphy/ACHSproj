#' @importFrom dplyr mutate left_join filter select lag if_else relocate
#' @importFrom lubridate year
NULL

#' Project payout annuity cashflows and reserves
#'
#' Appends mortality, survival, cashflow, and reserve columns to a
#' [projection] object's `data` tibble.
#'
#' @inheritParams projection
#' @param issue_age Integer age at policy issue.
#' @param benefit Annual benefit amount. Default `1`.
#' @param premium Single premium paid at time 0. If `NULL` (default), the
#'   premium is set to the present value of benefits — the net-zero fair
#'   premium at rate `disc`. Incompatible with `refund = TRUE`; supply an
#'   explicit value in that case.
#' @param qx_scalar Scalar multiplier applied to base mortality rates before
#'   improvement. Values below 1 lighten mortality; values above 1 load it.
#'   The adjusted rate is capped at 1. Default `1` (no adjustment).
#' @param disc Annual discount rate. Passed to [pv()].
#'
#' @return A [projection] object with the following columns appended to `@data`:
#' - `pol_yr`: Policy year.
#' - `age`: Integer attained age.
#' - `qx`: Base annual mortality rate from [qx_iamb].
#' - `mi`: Annual improvement factor from [scale_g2].
#' - `qx_adj`: Mortality rate after applying `qx_scalar` and Scale G2
#'   improvement from 2012 (the Scale G2 base year). Capped at 1.
#' - `tpx`: Cumulative survival probability from time 0.
#' - `premium`: Single premium paid at time 0; zero thereafter.
#' - `certain_cf`: Certain benefit cashflows as a [cf_vec]. Non-zero only
#'   during the certain period; scaled by survival probability to the end of
#'   the deferral period.
#' - `life_cf`: Life-contingent benefit cashflows as a [cf_vec]. Zero during
#'   the deferral and certain periods.
#' - `hist_pay`: Cumulative undecremented benefit payments to date.
#' - `death_cf`: Refund death benefit cashflows as a [cf_vec]. Non-zero only
#'   when `refund = TRUE` and unrecovered premium remains.
#' - `total_cf`: Sum of all cashflows as a [cf_vec].
#' - `disc`: Discount rate.
#' - `reserve`: PV of future total cashflows at each period.
#' @export
annuity_cf <- function(
  issue_age,
  gender = c("Female", "Male"),
  benefit = 1,
  premium = NULL,
  qx_scalar = 1,
  disc,
  defer_years = 0L,
  certain_years = 0L,
  life_contingent = TRUE,
  refund = FALSE,
  start_date = Sys.Date()
) {
  gender <- rlang::arg_match(gender)

  if (is.null(premium) && refund) {
    cli::cli_abort(
      "{.arg premium} must be supplied explicitly when {.arg refund} is {.val TRUE}."
    )
  }

  omega_age <- max(qx_iamb$age)
  n <- if (life_contingent) {
    max(omega_age - issue_age, defer_years + certain_years)
  } else {
    defer_years + certain_years
  }

  proj <- projection(
    start_date,
    n = n,
    freq = 12L,
    gender = gender,
    defer_years = defer_years,
    certain_years = certain_years,
    life_contingent = life_contingent,
    refund = refund
  )
  freq <- proj@freq
  pmt <- benefit / freq

  proj@data <- proj@data |>
    mutate(
      pol_yr = (t - 1) %/% 12 + 1,
      age = as.integer(issue_age + t / 12L),
      years_imp = year(date) - 2012L
    ) |>
    left_join(
      filter(qx_iamb, gender == .env$gender) |> select(age, qx),
      by = "age"
    ) |>
    left_join(
      filter(scale_g2, gender == .env$gender) |> select(age, mi),
      by = "age"
    ) |>
    mutate(
      qx = if_else(age > .env$omega_age, 1, qx),
      mi = if_else(age > .env$omega_age, 0, mi),
      qx_adj = pmin(qx * .env$qx_scalar * (1 - mi)^years_imp, 1),
      px = (1 - qx_adj)^(1 / freq),
      tpx = cumprod(lag(px, default = 1)),
      certain_cf = -cf_vec(
        if_else(
          pol_yr <= .env$defer_years |
            pol_yr > .env$defer_years + .env$certain_years,
          0,
          pmt * tpx[.env$defer_years * 12L + 1L]
        ),
        freq
      ),
      life_cf = -cf_vec(
        if_else(
          !.env$life_contingent |
            pol_yr <= .env$defer_years + .env$certain_years,
          0,
          pmt * lag(tpx, default = 0)
        ),
        freq
      ),
      hist_pay = cumsum((certain_cf + life_cf < 0) * pmt),
      death_cf = -cf_vec(
        if (.env$refund) {
          pmax(.env$premium - hist_pay, 0) * (lag(tpx, default = 1) - tpx)
        } else {
          0
        },
        freq
      ),
      total_cf = certain_cf + life_cf + death_cf,
      disc = disc,
      reserve = pv(total_cf, disc, rolling = TRUE)
    ) |>
    select(-px)

  premium_val <- if (is.null(premium)) -proj@data$reserve[[1]] else premium

  proj@data <- proj@data |>
    mutate(
      premium = cf_vec(if_else(t == 0L, premium_val, 0), freq),
      total_cf = premium + certain_cf + life_cf + death_cf
    ) |>
    relocate(premium, .before = certain_cf)

  proj
}
