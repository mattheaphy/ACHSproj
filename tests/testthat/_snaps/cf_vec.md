# cf_vec() errors on invalid frequency

    Code
      cf_vec(1:3, 5)
    Condition
      Error in `cf_vec()`:
      ! `freq` must be one of 12, 6, 4, 3, 2, and 1, not 5.

# c() errors when frequencies differ

    Code
      c(x, y)
    Condition
      Error in `vec_ptype2.cf_vec.cf_vec()`:
      ! Can't combine <cf_vec> vectors with different freq values (12 vs 1).

# vec_arith errors when frequencies differ

    Code
      x + y
    Condition
      Error in `vec_arith()`:
      ! Can't combine <cf_vec> vectors with different freq values (12 vs 1).

