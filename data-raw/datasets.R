library(readr)
library(dplyr)

qx_iamb <- read_csv(
  "data-raw/qx_iamb.csv",
  col_types = cols(
    age = col_integer(),
    qx = col_double(),
    gender = col_factor()
  )
)

scale_g2 <- read_csv(
  "data-raw/scale_g2.csv",
  col_types = cols(
    age = col_integer(),
    mi = col_double(),
    gender = col_factor()
  )
)

usethis::use_data(qx_iamb, scale_g2, overwrite = TRUE)
