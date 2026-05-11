# projection() errors on unparseable start_date

    Code
      projection("not-a-date", n = 3L)
    Condition
      Warning:
      All formats failed to parse. No formats found.
      Error in `projection()`:
      ! `start_date` could not be parsed as a date.

# projection() errors on non-scalar n

    Code
      projection("2025-01-01", n = c(3L, 4L))
    Condition
      Error in `projection()`:
      ! `n` must be a scalar integer.

# projection() errors on invalid freq

    Code
      projection("2025-01-01", n = 3L, freq = 5L)
    Condition
      Error in `projection()`:
      ! `freq` must be one of 12, 6, 4, 3, 2, and 1, not 5.

