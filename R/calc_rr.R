#' Calculates Risk Ratio.
#'
#' \code{calc_rr} calculates risk-ratio for Binary Outcome (y) and Binary
#' treatment variable, for given a vector of treatment levels, a vector of
#' possible outcome y and the count for each combination of treatment and y.
#' \code{calc_rr} and supports tidy-selection.
#'
#'
#' @param treatment A vector with two unique level or value.
#'
#' @param y A vector with two unique level or value.
#' @param n count for each combination of treatment and y.
#' @param treatment_ref_lvl Reference Level of treatment variable.
#' @param y_ref_lvl Reference level of y variable.
#'
#' @return A numeric value of risk ratio
#' @export
#' @importFrom dplyr .data
calc_rr <- function(treatment, y, n, treatment_ref_lvl = NULL,
                    y_ref_lvl = NULL) {
  trt_colname <- deparse(substitute(treatment))
  y_colname <- deparse(substitute(y))
  trt_colname_msg <- paste0("treatment variable `", trt_colname, "`")
  y_colname_msg <- paste0("outcome (y) variable `", y_colname, "`")
  check_na(treatment, trt_colname_msg)
  check_na(y, y_colname_msg)
  check_level(treatment, trt_colname_msg)
  check_level(y, y_colname_msg)
  check_param_null(treatment_ref_lvl, "treatment reference level")
  check_param_null(y_ref_lvl, "y reference level")

  dplyr::tibble(treatment, y, n) %>%
    dplyr::mutate(
      treatment = dplyr::if_else(treatment == treatment_ref_lvl, 0, 1),
      y = dplyr::if_else(y == y_ref_lvl, 0, 1)
    ) %>%
    dplyr::group_by(treatment) %>%
    dplyr::summarise(
      risk = calc_risk(.data$n)
    ) %>%
    dplyr::summarise(
      rr = .data$risk[2] / .data$risk[1]
    ) %>%
    dplyr::pull(.data$rr)
}




#' Calculates Risk Ratio from a given data frame
#'
#' \code{dcalc_rr} calculates the risk ratio directly from data and supports
#' tidy-selection.
#'
#'
#' @param data A data frame containing treatment and outcome (y) column.
#' @param treatment treatment column with two unique level or value.
#' @param y outcome column with two unique level or value.
#' @param treatment_ref_lvl Reference Level of treatment column.
#' @param y_ref_lvl Reference level of outcome (y) column.
#' @param group group column.
#'
#' @return A tibble containing the risk ratio.
#' @export
#' @importFrom dplyr .data
dcalc_rr <- function(data, treatment, y, treatment_ref_lvl = NULL,
                     y_ref_lvl = NULL, group = NULL) {
  check_data(data)
  trt_colname <- deparse(substitute(treatment))
  y_colname <- deparse(substitute(y))
  check_col_exist(trt_colname, data)
  check_col_exist(y_colname, data)
  trt <- dplyr::pull(data, {{ treatment }})
  outcome <- dplyr::pull(data, {{ y }})
  trt_colname_msg <- paste0("treatment variable `", trt_colname, "`")
  y_colname_msg <- paste0("outcome (y) variable `", y_colname, "`")
  check_na(trt, trt_colname_msg)
  check_na(outcome, y_colname_msg)
  if (!is.null(substitute(group))) {
    grp_colname <- deparse(substitute(group))
    grp_colname_msg <- paste0("group variable `", grp_colname, "`")
    check_col_exist(grp_colname, data)
    grp <- dplyr::pull(data, {{ group }})
    check_na(grp, grp_colname_msg)
  }
  check_level(trt, trt_colname_msg)
  check_level(outcome, y_colname_msg)
  check_param_null(treatment_ref_lvl, "treatment reference level")
  check_param_null(y_ref_lvl, "y reference level")

  data %>%
    dplyr::select({{ treatment }}, {{ y }}, {{ group }}) %>%
    dplyr::group_by({{ group }}) %>%
    dplyr::count({{ treatment }}, {{ y }}) %>%
    dplyr::rename("x" = {{ treatment }}, "y" = {{ y }}) %>%
    dplyr::group_by({{ group }}) %>%
    dplyr::summarise(
      rr = calc_rr(.data$x, .data$y, .data$n,
                   treatment_ref_lvl = treatment_ref_lvl,
                   y_ref_lvl = y_ref_lvl)
    )
}

