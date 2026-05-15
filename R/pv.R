#' @importFrom S7 new_generic method `method<-` new_S3_class class_numeric S7_dispatch
#' @importFrom dplyr select where
#' @importFrom purrr map
NULL

#' Present value of a cashflow object
#'
#' @param x A `cf_vec` or numeric vector of cashflow values.
#' @param disc Discount rate as a numeric vector of length 1 or the same
#'   length as `x`. A scalar is recycled across all periods.
#' @param disc_freq Periodicity of the discount rate as number of periods per
#'   year: `12` (monthly), `6` (bimonthly), `4` (quarterly), `3` (trimonthly),
#'   `2` (semi-annual), or `1` (annual, default).
#' @param rolling If `TRUE`, returns a numeric vector of length `length(x)`
#'   where element `i` is the prospective reserve at time `i`: the present
#'   value, discounted to time `i`, of cashflows `i+1` through `n`. The last
#'   element is always zero. Default `FALSE` returns a scalar.
#' @param ... Additional arguments passed to methods. For numeric vectors,
#'   `freq` sets the cashflow periodicity as number of periods per year:
#'   `12` (monthly, default), `6` (bimonthly), `4` (quarterly), `3` (trimonthly),
#'   `2` (semi-annual), or `1` (annual).
#' @return When `rolling = FALSE`, a scalar double. When `rolling = TRUE`, a
#'   numeric vector of length `length(x)`.
#' @export
pv <- new_generic(
  "pv",
  "x",
  function(x, disc, disc_freq = 1L, rolling = FALSE, ...) S7_dispatch()
)

method(pv, new_S3_class("cf_vec")) <- function(
  x,
  disc,
  disc_freq = 1L,
  rolling = FALSE
) {
  disc_freq <- validate_freq(disc_freq)
  n <- length(x)
  if (!is.numeric(disc)) {
    cli::cli_abort("{.arg disc} must be numeric.")
  }
  if (length(disc) == 1L) {
    disc <- rep(disc, n)
  } else if (length(disc) != n) {
    cli::cli_abort(
      "{.arg disc} must have length 1 or {n}, not {length(disc)}."
    )
  }
  fn <- if (rolling) pv_rolling_cashflows else pv_cashflows
  fn(vctrs::vec_data(x), disc, attr(x, "freq"), disc_freq)
}

method(pv, class_numeric) <- function(
  x,
  disc,
  disc_freq = 1L,
  rolling = FALSE,
  freq = 12L
) {
  pv(cf_vec(x, freq), disc, disc_freq = disc_freq, rolling = rolling)
}

method(pv, projection) <- function(
  x,
  disc,
  disc_freq = 1L,
  rolling = FALSE
) {
  if (missing(disc)) {
    disc <- x@data$disc
  }
  x@data |>
    select(where(\(col) inherits(col, "cf_vec"))) |>
    map(\(col) {
      pv(col, disc, disc_freq = disc_freq, rolling = rolling)
    }) |>
    tibble::as_tibble()
}

method(irr, projection) <- function(
  x,
  interval = c(0, 0.25),
  disc_freq = 1L,
  tol = 1e-16,
  maxiter = 50L
) {
  irr(
    x@data$total_cf,
    interval = interval,
    disc_freq = disc_freq,
    tol = tol,
    maxiter = maxiter
  )
}

method(plot, projection) <- function(x, ...) {
  rlang::check_installed(c("ggplot2", "scales", "tidyr"))
  x@data |>
    dplyr::select(t, life_cf, certain_cf, death_cf, reserve) |>
    tidyr::pivot_longer(-t, names_to = "Series", values_to = "Value") |>
    dplyr::mutate(
      Value = -Value,
      kind = dplyr::if_else(Series == "reserve", "Reserve", "Cashflow")
    ) |>
    ggplot2::ggplot(ggplot2::aes(x = t, y = Value, color = Series)) +
    ggplot2::geom_line(linewidth = 1.2) +
    ggplot2::theme_light(base_size = 13.2) +
    ggplot2::theme(
      strip.background = ggplot2::element_rect(fill = "#024D7C"),
      strip.text = ggplot2::element_text(face = "bold", color = "white"),
      axis.title = ggplot2::element_text(face = "bold"),
      plot.title = ggplot2::element_text(face = "bold"),
      legend.title = ggplot2::element_text(face = "bold"),
      legend.text = ggplot2::element_text(face = "plain")
    ) +
    ggplot2::scale_color_manual(
      values = c("#024D7C", "#77C4D5", "#D23138", "#FDCE07", "#BABF33")
    ) +
    ggplot2::scale_y_continuous(labels = scales::label_comma(accuracy = 1)) +
    ggplot2::facet_wrap(~kind, ncol = 1, scales = "free_y") +
    ggplot2::labs(title = "Payout annuity cashflows")
}

pv_cashflows <- function(cashflows, disc, cf_freq, disc_freq) {
  disc <- (1 + disc)^(disc_freq / cf_freq) - 1
  v <- c(1, cumprod(1 / (1 + disc[-length(disc)])))
  sum(cashflows * v)
}

pv_rolling_cashflows <- function(cashflows, disc, cf_freq, disc_freq) {
  disc <- (1 + disc)^(disc_freq / cf_freq) - 1
  v <- cumprod(1 / (1 + disc[-1]))
  weighted <- cashflows[-1] * v
  c(rev(cumsum(rev(weighted))), 0) / c(1, v)
}
