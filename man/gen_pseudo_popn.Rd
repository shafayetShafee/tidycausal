% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/genPseudoPopn.R
\name{gen_pseudo_popn}
\alias{gen_pseudo_popn}
\title{Generate Pseudo Population}
\usage{
gen_pseudo_popn(data, treatment, y, group = NULL)
}
\arguments{
\item{data}{a data frame.}

\item{treatment}{treatment column of the data frame.}

\item{y}{outcome column of the data frame.}

\item{group}{group column of the data frame by which pseudo population
need to be generated.}
}
\value{
A tibble with a \code{ns} column which contains the pseudo population count,
}
\description{
\code{gen_pseudo_popn} generates Pseudo Population using the Inverse Probability
method given a data frame with treatment and outcome (y) column. And it also possible
to create pseudo population grouped by another variable which exists in the given
frame.
}
