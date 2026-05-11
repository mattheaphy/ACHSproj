---
name: payout-cashflow-model
description: Payout annuity cashflow modelling using the ACHSproj package. Use when the user describes annuity contract assumptions in natural language and wants a projection, present value, IRR, plot, or sensitivity table. Translate natural language into annuity_cf() calls; never ask the user to supply code.
---

# Payout Cashflow Model

You are with the `ACHSproj` R package. Load it with `library(ACHSproj)` before 
running any code.

---

## Package API

### `annuity_cf()` — build a projection

```r
annuity_cf(
  issue_age,                      # integer age at issue
  gender        = "Female",       # "Female" or "Male"
  benefit       = 1,              # annual benefit amount
  premium       = NULL,           # single premium at time 0; NULL = fair premium (see below)
  qx_scalar     = 1,              # mortality multiplier (e.g. 0.8 = 80% of table)
  disc,                           # annual discount rate (e.g. 0.05)
  defer_years   = 0L,             # years before payments start
  certain_years = 0L,             # years of guaranteed payments
  life_contingent = TRUE,         # FALSE = certain annuity only
  refund        = FALSE,          # TRUE = return-of-premium death benefit
  start_date    = Sys.Date()
)
```

**`premium = NULL` (default):** the premium column is set to the present value
of benefits at rate `disc` — the net-zero fair premium. When using this
default, `irr(p)` will always equal `disc` by construction. To price at an
explicit amount, pass a numeric value. Note: `premium = NULL` is incompatible
with `refund = TRUE`; supply an explicit value in that case.

**`qx_scalar`:** a scalar multiplier applied to base mortality before
improvement factors. Values below 1 lighten mortality; values above 1 load it.
The resulting rate is capped at 1. Useful for sensitivity testing or loading
assumptions.

Returns a `projection` object. Cashflows live in `p@data`:

| Column | Sign | Description |
|---|---|---|
| `premium` | + | Single premium inflow at time 0 |
| `certain_cf` | − | Guaranteed benefit payments during the certain period |
| `life_cf` | − | Life-contingent payments after the certain period |
| `death_cf` | − | Return-of-premium death benefit (when `refund = TRUE`) |
| `total_cf` | ± | Sum of all cashflows |
| `reserve` | | Prospective reserve at each period |
| `tpx` | | Cumulative survival probability |

Mortality basis: IAM-B table with Scale G2 improvement from 2012.

### `pv()` — present value

```r
pv(p)                          # scalar PV of each cf_vec column, at stored disc
pv(p, disc = 0.04)             # override discount rate
pv(p, rolling = TRUE)          # prospective reserve vector (same as p@data$reserve)
```

Returns a one-row tibble with columns `premium`, `certain_cf`, `life_cf`,
`death_cf`, `total_cf`.

### `irr()` — cost of funds

```r
irr(p)                         # annual IRR of total_cf
irr(p, disc_freq = 12L)        # monthly effective IRR
```

The IRR of `total_cf` is the **cost of funds** — the rate at which the
insurer breaks even.

### `plot()` — visualise

```r
plot(p)    # two-panel chart: cashflow components + prospective reserve
```

---

## Translating natural language to code

| User says | Parameter |
|---|---|
| "age X", "issued at X", "X-year-old" | `issue_age = X` |
| "male" / "female" | `gender = "Male"` / `"Female"` |
| "$X annual benefit", "pays $X per year" | `benefit = X` |
| "$X single premium", "priced at $X" | `premium = X` |
| "fair premium", "net premium", "price to break even" | `premium = NULL` (default) |
| "X% mortality", "X% of table", "mortality loading of X%" | `qx_scalar = X/100` |
| "lighten mortality by X%", "X% mortality improvement load" | `qx_scalar = 1 - X/100` |
| "X% discount rate", "using X% interest" | `disc = X/100` |
| "X-year deferral", "deferred X years" | `defer_years = XL` |
| "X-year certain period", "guaranteed X years" | `certain_years = XL` |
| "certain annuity", "no life contingency" | `life_contingent = FALSE` |
| "return of premium", "refund on death" | `refund = TRUE` |

Default gender is Female unless specified. Default `start_date` is today.

---

## Sensitivity analysis patterns

Always build a tidy tibble so results are easy to read and extend.

### Vary a single assumption

```r
library(purrr)
library(dplyr)
library(tibble)

ages <- c(55, 60, 65, 70)

map_dfr(ages, \(age) {
  p <- annuity_cf(issue_age = age, benefit = 10000, premium = 80000,
                  disc = 0.05, defer_years = 5L, certain_years = 3L,
                  refund = TRUE)
  tibble(issue_age = age, pv_total = pv(p)$total_cf, irr = irr(p))
})
```

### Vary two assumptions (grid)

```r
params <- expand.grid(
  issue_age     = c(55, 60, 65),
  certain_years = 0:5
)

pmap_dfr(params, \(issue_age, certain_years) {
  p <- annuity_cf(issue_age = issue_age, benefit = 10000, premium = 80000,
                  disc = 0.05, defer_years = 5L,
                  certain_years = certain_years, refund = TRUE)
  tibble(issue_age, certain_years, pv_total = pv(p)$total_cf)
})
```

---

## Output guidance

- After building a projection, always show `pv(p)` and `irr(p)` unless the
  user asked for something more specific.
- For sensitivity tables, format currency with `scales::dollar()` or
  `scales::comma()` and rates with `scales::percent(accuracy = 0.01)`.
- Offer `plot(p)` after any single-scenario build.
- Keep code blocks self-contained and runnable — assume `devtools::load_all()`
  has already been called.
