#' IAM-B mortality rates and Scale G2 improvement factors
#'
#' Individual annuity mortality and improvement scales.
#'
#' @details
#' ## `qx_iamb`
#' IAM-B table mortality rates by age and gender. A tibble with 3 columns:
#' - `age`: Integer age.
#' - `qx`: Probability of death within one year.
#' - `gender`: Factor with levels `Female` and `Male`.
#'
#' ## `scale_g2`
#' Scale G2 annual mortality improvement factors by age and gender. A tibble
#' with 3 columns:
#' - `age`: Integer age.
#' - `mi`: Annual mortality improvement rate.
#' - `gender`: Factor with levels `Female` and `Male`.
#'
#' @name mortality_tables
#' @source <https://mort.soa.org>
NULL

#' @rdname mortality_tables
"qx_iamb"

#' @rdname mortality_tables
"scale_g2"
