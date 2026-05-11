test_that("pv() discounts a cf_vec with a scalar rate", {
  x <- cf_vec(c(100, 100, 100), 1L)
  r <- 0.05
  expect_equal(pv(x, r), 100 + 100 / 1.05 + 100 / 1.05^2)
})

test_that("pv() discounts a cf_vec with a vector rate", {
  x <- cf_vec(c(100, 200), 1L)
  r <- c(0.05, 0.06)
  expect_equal(pv(x, r), 100 + 200 / 1.05)
})

test_that("pv() scalar and length-n discount give same result when equal", {
  x <- cf_vec(c(50, 50, 50, 50), 4L)
  expect_equal(pv(x, 0.02), pv(x, rep(0.02, 4)))
})

test_that("pv() disc_freq converts rate to cashflow basis", {
  x <- cf_vec(c(100, 100, 100), 12L)
  monthly_rate <- (1.05)^(1 / 12) - 1
  expect_equal(
    pv(x, 0.05, disc_freq = 1L),
    pv(x, monthly_rate, disc_freq = 12L)
  )
})

test_that("pv() numeric method matches cf_vec method", {
  x <- c(100, 200, 300)
  expect_equal(pv(x, 0.05), pv(cf_vec(x, 12L), 0.05))
  expect_equal(pv(x, 0.05, freq = 1L), pv(cf_vec(x, 1L), 0.05))
})

test_that("pv() numeric method respects disc_freq", {
  x <- c(100, 100)
  monthly_rate <- (1.05)^(1 / 12) - 1
  expect_equal(
    pv(x, 0.05, disc_freq = 1L, freq = 12L),
    pv(x, monthly_rate, disc_freq = 12L, freq = 12L)
  )
})

test_that("pv() rolling returns vector of future cashflow PVs", {
  x <- cf_vec(c(100, 200, 300), 1L)
  result <- pv(x, 0.05, rolling = TRUE)
  expect_equal(result, c(200 / 1.05 + 300 / 1.05^2, 300 / 1.05, 0))
})

test_that("pv() rolling last element is always zero", {
  x <- cf_vec(c(50, 100, 150), 4L)
  expect_equal(tail(pv(x, 0.02, rolling = TRUE), 1), 0)
})

test_that("pv() rolling[1] equals scalar PV minus first cashflow", {
  x <- cf_vec(c(100, 200, 300), 1L)
  expect_equal(pv(x, 0.05, rolling = TRUE)[[1]], pv(x, 0.05) - 100)
})

test_that("pv() numeric rolling matches cf_vec rolling", {
  x <- c(100, 200, 300)
  expect_equal(
    pv(x, 0.05, rolling = TRUE, freq = 1L),
    pv(cf_vec(x, 1L), 0.05, rolling = TRUE)
  )
})

test_that("pv() errors when discount is non-numeric", {
  expect_snapshot(error = TRUE, pv(cf_vec(1:3), "0.05"))
})

test_that("pv() errors when discount length is wrong", {
  expect_snapshot(error = TRUE, pv(cf_vec(1:3), c(0.05, 0.06)))
})

test_that("pv() errors on invalid disc_freq", {
  expect_snapshot(error = TRUE, pv(cf_vec(1:3), 0.05, disc_freq = 5L))
})
