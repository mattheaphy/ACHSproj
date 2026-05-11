test_that("cf_vec() creates a cf_vec with correct frequency", {
  x <- cf_vec(c(100, 200, 300), 12L)
  expect_s3_class(x, "cf_vec")
  expect_equal(attr(x, "freq"), 12L)
})

test_that("cf_vec() coerces integer input to double", {
  x <- cf_vec(1L:3L, 1L)
  expect_type(vctrs::vec_data(x), "double")
})

test_that("cf_vec() defaults to monthly frequency", {
  x <- cf_vec(1:3)
  expect_equal(attr(x, "freq"), 12L)
})

test_that("cf_vec() coerces numeric frequency to integer", {
  x <- cf_vec(1:3, 4)
  expect_equal(attr(x, "freq"), 4L)
})

test_that("cf_vec() errors on invalid frequency", {
  expect_snapshot(error = TRUE, cf_vec(1:3, 5))
})

test_that("new_cf_vec() skips validation", {
  x <- new_cf_vec(c(1, 2), 12L)
  expect_s3_class(x, "cf_vec")
})

test_that("c() preserves cf_vec class when frequencies match", {
  x <- cf_vec(1:2, 4L)
  y <- cf_vec(3:4, 4L)
  expect_s3_class(c(x, y), "cf_vec")
})

test_that("c() errors when frequencies differ", {
  x <- cf_vec(1:2, 12L)
  y <- cf_vec(3:4, 1L)
  expect_snapshot(error = TRUE, c(x, y))
})

test_that("vec_ptype_abbr.cf_vec() returns correct abbreviations", {
  expect_equal(vctrs::vec_ptype_abbr(cf_vec(1, 12L)), "cf<mo>")
  expect_equal(vctrs::vec_ptype_abbr(cf_vec(1, 6L)), "cf<bmo>")
  expect_equal(vctrs::vec_ptype_abbr(cf_vec(1, 4L)), "cf<qtr>")
  expect_equal(vctrs::vec_ptype_abbr(cf_vec(1, 3L)), "cf<tmo>")
  expect_equal(vctrs::vec_ptype_abbr(cf_vec(1, 2L)), "cf<sa>")
  expect_equal(vctrs::vec_ptype_abbr(cf_vec(1, 1L)), "cf<yr>")
})

test_that("vec_math preserves class and computes correctly", {
  x <- cf_vec(c(-100, 200, 300), 12L)
  expect_s3_class(abs(x), "cf_vec")
  expect_equal(vctrs::vec_data(abs(x)), c(100, 200, 300))
  expect_s3_class(cumsum(x), "cf_vec")
  expect_equal(vctrs::vec_data(cumsum(x)), c(-100, 100, 400))
})

test_that("vec_arith preserves class and computes correctly", {
  x <- cf_vec(c(100, 200), 4L)
  y <- cf_vec(c(10, 20), 4L)
  expect_s3_class(x + y, "cf_vec")
  expect_equal(vctrs::vec_data(x + y), c(110, 220))
  expect_s3_class(x * 2, "cf_vec")
  expect_equal(vctrs::vec_data(x * 2), c(200, 400))
})

test_that("vec_arith errors when frequencies differ", {
  x <- cf_vec(c(100, 200), 12L)
  y <- cf_vec(c(10, 20), 1L)
  expect_snapshot(error = TRUE, x + y)
})

test_that("unary minus negates values and preserves class and freq", {
  x <- cf_vec(c(1, -2, 3), 4L)
  nx <- -x
  expect_s3_class(nx, "cf_vec")
  expect_equal(attr(nx, "freq"), 4L)
  expect_equal(vctrs::vec_data(nx), c(-1, 2, -3))
})
