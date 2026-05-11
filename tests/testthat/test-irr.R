test_that("irr() of c(-1, 1.1) with freq=1 is near 0.1", {
  expect_equal(irr(c(-1, 1.1), freq = 1L), 0.1, tolerance = 1e-6)
})

test_that("irr() cf_vec method matches numeric method", {
  x <- cf_vec(c(-1, 1.1), 1L)
  expect_equal(irr(x), irr(c(-1, 1.1), freq = 1L))
})

test_that("irr() disc_freq converts annual to monthly rate correctly", {
  x <- cf_vec(c(-1, 1.1), 1L)
  r_annual <- irr(x, disc_freq = 1L)
  r_monthly <- irr(x, disc_freq = 12L)
  expect_equal((1 + r_monthly)^12 - 1, r_annual, tolerance = 1e-6)
})

test_that("irr() returns a scalar numeric", {
  x <- cf_vec(c(-1, 1.1), 1L)
  r <- irr(x)
  expect_true(is.numeric(r))
  expect_length(r, 1L)
})
