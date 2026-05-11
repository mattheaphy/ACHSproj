# ACHSproj v0.0.0.9000 (development version)

- Added `cf_vec()`, a vctrs-based cashflow vector class with a `freq` attribute
  (periods per year: 1, 2, 3, 4, 6, or 12).
- Added `pv()`, an S7 generic for present value with methods for `cf_vec`,
  plain numeric vectors, and `projection` objects. Supports per-period or
  annual discount rates via `disc_freq`. The `rolling = TRUE` option returns a
  prospective reserve vector rather than a scalar.
- Added `irr()`, an S7 generic for internal rate of return with methods for
  `cf_vec`, plain numeric vectors, and `projection` objects. On a `projection`,
  returns the cost of funds (the IRR of `total_cf`).
- Added `annuity_cf()`, which builds a monthly payout annuity projection
  including mortality (IAM-B with Scale G2 improvement), survival, cashflow,
  and reserve columns. Supports deferral periods, certain periods,
  life-contingent payments, and an optional return-of-premium death benefit.
- Added `projection` S7 class with a `plot()` method that renders a two-panel
  cashflow and reserve chart.
- Added `qx_iamb` and `scale_g2` mortality datasets.
