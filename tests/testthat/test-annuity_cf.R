p <- annuity_cf(
  issue_age = 60,
  benefit = 8,
  premium = 100,
  defer_years = 2L,
  certain_years = 3L,
  refund = TRUE,
  disc = 0.05,
  start_date = "2026-05-06"
)

test_that("irr(p) returns a scalar numeric", {
  r <- irr(p)
  expect_true(is.numeric(r))
  expect_length(r, 1L)
})

test_that("plot(p) returns a ggplot object", {
  expect_s3_class(plot(p), "ggplot")
})

test_that("certain_cf: first 25 values are zero", {
  expect_equal(as.numeric(p@data$certain_cf[1:25]), rep(0, 25))
})

test_that("certain_cf: exactly 36 non-zero values", {
  expect_equal(sum(p@data$certain_cf != 0), 36L)
})

test_that("life_cf: first 61 values are zero", {
  expect_equal(as.numeric(p@data$life_cf[1:61]), rep(0, 61))
})

test_that("death_cf: not all zero, but first and last values are zero", {
  expect_false(all(p@data$death_cf == 0))
  expect_equal(as.numeric(p@data$death_cf[[1]]), 0)
  expect_equal(as.numeric(tail(p@data$death_cf, 1)), 0)
})

test_that("reserve[1] equals pv(p)$total_cf minus pv(p)$premium", {
  pv_result <- pv(p)
  expect_equal(p@data$reserve[[1]], pv_result$total_cf - pv_result$premium)
})

test_that("pv(p, irr(p))$total_cf is approximately zero", {
  expect_equal(pv(p, irr(p))$total_cf, 0, tolerance = 1e-4)
})

test_that("life_contingent=TRUE projects to (omega_age - issue_age)*12+1 rows", {
  expect_equal(nrow(p@data), (120L - 60L) * 12L + 1L)
})

test_that("life_contingent=FALSE truncates projection to (defer+certain)*12+1 rows", {
  p2 <- annuity_cf(
    issue_age = 60,
    benefit = 8,
    premium = 100,
    defer_years = 2L,
    certain_years = 3L,
    life_contingent = FALSE,
    disc = 0.05,
    start_date = "2026-05-06"
  )
  expect_equal(nrow(p2@data), (2L + 3L) * 12L + 1L)
})
