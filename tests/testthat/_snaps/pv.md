# pv() errors when discount is non-numeric

    Code
      pv(cf_vec(1:3), "0.05")
    Condition
      Error in `method(pv, new_S3_class("cf_vec"))`:
      ! `disc` must be numeric.

# pv() errors when discount length is wrong

    Code
      pv(cf_vec(1:3), c(0.05, 0.06))
    Condition
      Error in `method(pv, new_S3_class("cf_vec"))`:
      ! `disc` must have length 1 or 3, not 2.

# pv() errors on invalid disc_freq

    Code
      pv(cf_vec(1:3), 0.05, disc_freq = 5L)
    Condition
      Error in `method(pv, new_S3_class("cf_vec"))`:
      ! `disc_freq` must be one of 12, 6, 4, 3, 2, and 1, not 5.

