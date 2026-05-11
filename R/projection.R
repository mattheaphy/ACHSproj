#' @importFrom S7 new_class new_property new_object S7_object class_data.frame class_numeric class_character class_logical method `method<-`
#' @importFrom cli format_inline
#' @importFrom lubridate ymd %m+%
NULL

#' Projection class
#'
#' @param start_date Projection start date. Parsed via [lubridate::ymd()].
#' @param n Scalar integer number of projection years.
#' @param freq Periodicity of the projection as number of periods per year:
#'   `12` (monthly, default), `6` (bimonthly), `4` (quarterly), `3` (trimonthly),
#'   `2` (semi-annual), or `1` (annual).
#' @param gender `"Female"` or `"Male"`.
#' @param defer_years Number of years before payments start. Default `0`.
#' @param certain_years Number of years where payments are guaranteed regardless
#'   of survivorship. Default `0`.
#' @param life_contingent If `TRUE` (default), life-contingent payments are
#'   assumed. If `FALSE`, a certain annuity is assumed.
#' @param refund If `TRUE`, upon death a benefit is paid equal to the premium
#'   less cumulative undecremented past payments. Default `FALSE`.
#' @return A `projection` object.
#'
#' @details
#' # Properties
#' - `data`: A tibble with columns `t` (months elapsed since `start_date`) and
#'   `date` ([Date][base::Date]), one row per projection period plus time 0.
#' - `freq`: Integer. Periodicity as number of periods per year.
#' - `gender`: `"Female"` or `"Male"`.
#' - `defer_years`: Integer. Number of years before payments start.
#' - `certain_years`: Integer. Number of years where payments are guaranteed.
#' - `life_contingent`: Logical. Whether payments are life-contingent.
#' - `refund`: Logical. Whether a death benefit refunds the unrecovered premium.
#' @export
projection <- new_class(
  "projection",
  properties = list(
    data = new_property(
      class = class_data.frame,
      setter = function(self, value) {
        self@data <- tibble::as_tibble(value)
        self
      }
    ),
    freq = new_property(
      class = class_numeric,
      setter = function(self, value) {
        self@freq <- as.integer(value)
        self
      }
    ),
    gender = new_property(
      class = class_character,
      validator = function(value) {
        if (!rlang::is_scalar_character(value)) {
          cli::cli_abort("{.arg gender} must be a scalar string.", call = NULL)
        }
        rlang::arg_match(value, c("Female", "Male"))
        NULL
      }
    ),
    defer_years = new_property(
      class = class_numeric,
      setter = function(self, value) {
        self@defer_years <- as.integer(value)
        self
      },
      validator = function(value) {
        if (!rlang::is_scalar_integerish(value)) {
          cli::cli_abort(
            "{.arg defer_years} must be a scalar integer.",
            call = NULL
          )
        }
        NULL
      }
    ),
    certain_years = new_property(
      class = class_numeric,
      setter = function(self, value) {
        self@certain_years <- as.integer(value)
        self
      },
      validator = function(value) {
        if (!rlang::is_scalar_integerish(value)) {
          cli::cli_abort(
            "{.arg certain_years} must be a scalar integer.",
            call = NULL
          )
        }
        NULL
      }
    ),
    life_contingent = new_property(
      class = class_logical,
      validator = function(value) {
        if (!rlang::is_scalar_logical(value)) {
          cli::cli_abort(
            "{.arg life_contingent} must be a scalar logical.",
            call = NULL
          )
        }
        NULL
      }
    ),
    refund = new_property(
      class = class_logical,
      validator = function(value) {
        if (!rlang::is_scalar_logical(value)) {
          cli::cli_abort("{.arg refund} must be a scalar logical.", call = NULL)
        }
        NULL
      }
    )
  ),
  constructor = function(
    start_date,
    n,
    freq = 12L,
    gender = c("Female", "Male"),
    defer_years = 0L,
    certain_years = 0L,
    life_contingent = TRUE,
    refund = FALSE
  ) {
    gender <- rlang::arg_match(gender)
    freq <- validate_freq(freq)

    start_date <- ymd(start_date)
    if (is.na(start_date)) {
      cli::cli_abort("{.arg start_date} could not be parsed as a date.")
    }

    if (!rlang::is_scalar_integerish(n)) {
      cli::cli_abort("{.arg n} must be a scalar integer.")
    }
    n <- as.integer(n)
    step <- 12L / freq

    data <- tibble::tibble(
      t = seq(0, 12 * n, by = step),
      date = start_date %m+% months(t)
    )

    new_object(
      S7_object(),
      data = data,
      freq = freq,
      gender = gender,
      defer_years = defer_years,
      certain_years = certain_years,
      life_contingent = life_contingent,
      refund = refund
    )
  },
  validator = function(self) {
    allowed <- c(12L, 6L, 4L, 3L, 2L, 1L)
    if (!self@freq %in% allowed) {
      cli::cli_abort(
        "{.arg freq} must be one of {.val {allowed}}, not {.val {self@freq}}.",
        call = NULL
      )
    }
    d <- self@data
    if (!"t" %in% names(d)) {
      cli::cli_abort("{.arg data} must have a {.field t} column.", call = NULL)
    }
    if (!"date" %in% names(d)) {
      cli::cli_abort(
        "{.arg data} must have a {.field date} column.",
        call = NULL
      )
    }
    if (!is.numeric(d[["t"]])) {
      cli::cli_abort(
        "The {.field t} column must be numeric, not {.cls {class(d[['t']])}}.",
        call = NULL
      )
    }
    if (!inherits(d[["date"]], "Date")) {
      cli::cli_abort(
        "The {.field date} column must be {.cls Date}, not {.cls {class(d[['date']])}}.",
        call = NULL
      )
    }
    NULL
  }
)

method(format, projection) <- function(x, ...) {
  c(
    format_inline("{.cls projection}"),
    format_inline("{.field @freq}: {x@freq}"),
    format_inline("{.field @gender}: {x@gender}"),
    format_inline("{.field @defer_years}: {x@defer_years}"),
    format_inline("{.field @certain_years}: {x@certain_years}"),
    format_inline("{.field @life_contingent}: {x@life_contingent}"),
    format_inline("{.field @refund}: {x@refund}"),
    format_inline("{.field @data}:"),
    format(x@data)
  )
}

method(print, projection) <- function(x, ...) {
  cat(format(x, ...), sep = "\n")
  invisible(x)
}
