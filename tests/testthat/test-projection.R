test_that("projection() constructs a projection object", {
  p <- projection("2025-01-01", n = 3L)
  expect_true(S7::S7_inherits(p, projection))
})

test_that("projection() defaults to monthly frequency", {
  p <- projection("2025-01-01", n = 3L)
  expect_equal(p@freq, 12L)
})

test_that("projection() data is a tibble", {
  p <- projection("2025-01-01", n = 3L)
  expect_s3_class(p@data, "tbl_df")
})

test_that("projection() data has n*freq+1 rows", {
  p <- projection("2025-01-01", n = 3L)
  expect_equal(nrow(p@data), 37L)
})

test_that("projection() t column is monthly integer sequence for annual freq", {
  p <- projection("2025-01-01", n = 3L, freq = 1L)
  expect_equal(p@data$t, c(0L, 12L, 24L, 36L))
})

test_that("projection() date sequence is correct for monthly", {
  p <- projection("2025-01-01", n = 1L, freq = 12L)
  expected <- as.Date(c(
    "2025-01-01",
    "2025-02-01",
    "2025-03-01",
    "2025-04-01",
    "2025-05-01",
    "2025-06-01",
    "2025-07-01",
    "2025-08-01",
    "2025-09-01",
    "2025-10-01",
    "2025-11-01",
    "2025-12-01",
    "2026-01-01"
  ))
  expect_equal(p@data$date, expected)
})

test_that("projection() date sequence is correct for quarterly", {
  p <- projection("2025-01-01", n = 1L, freq = 4L)
  expected <- as.Date(c(
    "2025-01-01",
    "2025-04-01",
    "2025-07-01",
    "2025-10-01",
    "2026-01-01"
  ))
  expect_equal(p@data$date, expected)
})

test_that("projection() accepts flexible start_date formats", {
  p <- projection("20250101", n = 1L)
  expect_equal(p@data$date[[1L]], as.Date("2025-01-01"))
})

test_that("projection() errors on unparseable start_date", {
  expect_snapshot(error = TRUE, projection("not-a-date", n = 3L))
})

test_that("projection() errors on non-scalar n", {
  expect_snapshot(error = TRUE, projection("2025-01-01", n = c(3L, 4L)))
})

test_that("projection() errors on invalid freq", {
  expect_snapshot(error = TRUE, projection("2025-01-01", n = 3L, freq = 5L))
})
