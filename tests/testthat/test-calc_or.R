library(dplyr)

test_that("Checking for simple single or calculation", {
  # manual
  dt11 <- wcgs %>%
    count(smoke, chd69) %>%
    summarise(
      or = (n[4] * n[1]) / (n[2] * n[3])
    )

  dt12 <- wcgs %>%
    count(smoke, chd69) %>%
    summarise (
      or = calc_or(smoke, chd69, n, "No", "No")
    )

  dt13 <- wcgs %>%
    dcalc_or(smoke, chd69 , "No", "No")

  expect_identical(dt11, dt12)
  expect_identical(dt11, dt13)
  expect_identical(dt12, dt13)
})


test_that("Checking for grouped or calculation", {
  # manual
  dt21 <- wcgs %>%
    filter(!is.na(arcus)) %>%
    group_by(arcus) %>%
    count(chd69, smoke) %>%
    summarise(
      or = calc_or(smoke, chd69, n, "No", "No")
    )

  dt22 <- wcgs %>%
    filter(!is.na(arcus)) %>%
    dcalc_or(smoke, chd69, "No", "No", group = arcus)

  expect_identical(dt21, dt22)
})


test_that("Checking for calculation if ref level changed (single value)", {
  # manual
  dt31 <- wcgs %>%
    mutate(
      smoke = if_else(smoke == "No", "Yes", "No"),
      chd69 = if_else(chd69 == "No", "Yes", "No")
    ) %>%
    count(smoke, chd69) %>%
    summarise(
      or = (n[4] * n[1]) / (n[2] * n[3])
    )

  dt32 <- wcgs %>%
    count(smoke, chd69) %>%
    summarise (
      or = calc_or(smoke, chd69, n, "Yes", "Yes")
    )

  dt33 <- wcgs %>%
    dcalc_or(smoke, chd69, "Yes", "Yes")

  expect_identical(dt31, dt32)
  expect_identical(dt31, dt33)
  expect_identical(dt32, dt33)
})


test_that("Checking for calculation if ref level changed (grouped value)", {
  # manual
  dt41 <- wcgs %>%
    filter(!is.na(arcus)) %>%
    group_by(arcus) %>%
    count(chd69, smoke) %>%
    summarise(
      or = calc_or(smoke, chd69, n, "Yes", "Yes")
    )

  dt42 <- wcgs %>%
    filter(!is.na(arcus)) %>%
    dcalc_or(smoke, chd69, "Yes", "Yes", group = arcus)

  expect_identical(dt41, dt42, )
})


test_that("Expecting errors in calc_or", {
  expect_error(
    wcgs %>%
      count(smoke, chd69) %>%
      summarise (
        or = calc_or(smoke, chd69, n)
      ),
    "Could not determine the treatment reference level"
  )

  expect_error(
    wcgs %>%
      count(smoke, chd69) %>%
      summarise (
        or = calc_or(smoke, chd69, n, y_ref_lvl = "No")
      ),
    "Could not determine the treatment reference level"
  )

  expect_error(
    wcgs %>%
      count(smoke, chd69) %>%
      summarise (
        or = calc_or(smoke, chd69, n, "No")
      ),
    "Could not determine the y reference level"
  )
})


test_that("Expecting errors in dcalc_or", {
  expect_error(
    wcgs %>%
      dcalc_or(smoke, chd69),
    "Could not determine the treatment reference level"
  )

  expect_error(
    wcgs %>%
      dcalc_or(smoke, chd69, y_ref_lvl = "No"),
    "Could not determine the treatment reference level"
  )

  expect_error(
    wcgs %>%
      dcalc_or(smoke, chd69, "No"),
    "Could not determine the y reference level"
  )
})


test_that("Expecting errors in or functions for treatment not being binary", {
  expect_error(
    wcgs %>%
      count(agec, chd69) %>%
      summarise (
        or = calc_or(agec, chd69, n, "No", "No")
      ),
    "treatment variable *."
  )

  expect_error(
    wcgs %>%
      dcalc_or(agec, chd69, "No", "No"),
    "treatment variable *."
  )
})


test_that("Expecting errors in or functions for outcome not being binary", {
  expect_error(
    wcgs %>%
      count(agec, smoke) %>%
      summarise (
        or = calc_or(smoke, agec, n, "No", "No")
        # This doesn't make sense much IKR,
        # but we need to test anyway
      ),
    "outcome .*"
    )

  expect_error(
    wcgs %>%
      dcalc_or(smoke, agec, "No", "No"),
    "outcome .*"
    # Yeah again, This doesn't make sense much IKR,
    # but we need to test anyway
    )
  }
)

test_that("Expecting errors in or functions for NA values in treatment `chol`", {
  expect_error(
    wcgs %>%
      count(arcus, chd69) %>%
      summarise (
        or = calc_or(arcus, chd69, n, "No", "No")
      ),
    "There are missing values in treatment"
    )

  expect_error(
    wcgs %>%
      dcalc_or(arcus, chd69, "No", "No"),
    "There are missing values in treatment"
    )
  }
)

test_that("Expecting errors in or functions for NA values in outcome `chol`", {
  expect_error(
    wcgs %>%
      count(chol, smoke) %>%
      summarise (or = calc_or(smoke, chol, n, "No", "No")),
    "There are missing values .*"
    )

  expect_error(
    wcgs %>%
      dcalc_or(smoke, chol, "No", "No"),
    "There are missing values .*"
    )
  }
)

test_that("Expecting errors in dcalc_or for NA values in group variable `arcus`", {
  expect_error(
    wcgs %>%
      dcalc_or(smoke, chd69, "No", "No", arcus),
    "There are missing values .*"
    )
  }
)

test_that("Expecting errors in dcalc_or if wrong column is given", {
  # wrong treatment column
  expect_error(
    wcgs %>%
      dcalc_or(smoker, chd69, "No", "No"),
    "Column `\\w+` doesn't exist in the data"
  )

  # wrong y column
  expect_error(
    wcgs %>%
      dcalc_or(smoke, chd, "No", "No"),
    "Column `\\w+` doesn't exist in the data"
  )

  # wrong group column
  expect_error(
    wcgs %>%
      dcalc_or(smoke, chd69, "No", "No", age_cat),
    "Column `\\w+` doesn't exist in the data"
  )
})
