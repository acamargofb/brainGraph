% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/glm_stats.R
\name{GLM statistics}
\alias{GLM statistics}
\alias{coef.bg_GLM}
\alias{confint.bg_GLM}
\alias{fitted.bg_GLM}
\alias{residuals.bg_GLM}
\alias{deviance.bg_GLM}
\alias{coeff_determ}
\alias{df.residual.bg_GLM}
\alias{sigma.bg_GLM}
\alias{vcov.bg_GLM}
\alias{coeff_table}
\alias{anova.bg_GLM}
\title{Extract model fit statistics from a bg_GLM object}
\usage{
\method{coef}{bg_GLM}(object, ...)

\method{confint}{bg_GLM}(object, parm, level = 0.95, ...)

\method{fitted}{bg_GLM}(object, ...)

\method{residuals}{bg_GLM}(object, type = c("response", "partial"), ...)

\method{deviance}{bg_GLM}(object, ...)

coeff_determ(object, adjusted = FALSE)

\method{df.residual}{bg_GLM}(object, ...)

\method{sigma}{bg_GLM}(object, ...)

\method{vcov}{bg_GLM}(object, ...)

coeff_table(object, CI = FALSE, level = 0.95)

\method{anova}{bg_GLM}(object, region = NULL, ...)
}
\arguments{
\item{object}{A \code{bg_GLM} object}

\item{...}{Unused}

\item{parm}{Vector of parameters to calculate confidence intervals for.
Default is to use all parameters}

\item{level}{The confidence level. Default: \code{0.95}}

\item{type}{Character string specifying the type of residuals to return.
Default: \code{'response'}}

\item{adjusted}{Logical indicating whether to calculate the adjusted
R-squared. Default: \code{FALSE}}

\item{CI}{Logical indicating whether to include confidence intervals of
parameter estimates in the coefficient summary table. Default: \code{FALSE}}

\item{region}{Character vector indicating the region(s) to calculate ANOVA
statistics for. Default: \code{NULL} (use all regions)}
}
\value{
A named numeric vector, matrix, or array, depending on the function:
  \item{coef}{Matrix in which rownames are parameter names and column names
    are regions}
  \item{fitted,residuals}{Matrix in which rownames are Study ID's and column
    names are regions. If \code{type='partial'}, an array is returned in
    which columns are \emph{terms} and the 3rd dimension are regions}
  \item{deviance,coeff_determ,sigma}{Numeric vector with elements for each
    region}
  \item{df.residual}{Single integer; the degrees of freedom}
  \item{confint,vcov,coeff_table}{Numeric array; the extent of the third
    dimension equals the number of regions}

\code{anova} returns a \emph{list} of tables of class \code{anova}
}
\description{
These functions extract or calculate model fit statistics of a
\code{bg_GLM} object. These can be found in the output from
\code{\link[stats]{summary.lm}}.
}
\details{
These mimic the same functions that operate on \code{\link{lm}} objects, and
include:
\describe{
  \item{coef}{Regression coefficients (parameter estimates)}
  \item{confint}{Confidence intervals (by default, 95\%) for parameter
    estimates}
  \item{fitted}{Fitted (mean) values; i.e., the design matrix multiplied by
    the parameter estimates, \eqn{X \hat{\beta}}}
  \item{residuals}{Model residuals; i.e., the response/outcome variable minus
    the \emph{fitted} values. Partial residuals can also be calculated}
  \item{deviance}{Model deviance, or the \emph{residual sum of squares}}
  \item{coeff_determ}{Calculate the \emph{coefficient of determination} (or
    \eqn{R^2}), adjusted or unadjusted}
  \item{df.residual}{Residual degrees of freedom}
  \item{sigma}{Residual standard deviation, sometimes called the \emph{root
    mean squared error (RMSE)}}
  \item{vcov}{Variance-covariance matrix of the model parameters}
}

\code{coeff_table} returns model coefficients, standard errors, T-statistics,
and P-values for all model terms and regions in a \code{bg_GLM} object. This
is the same as running \code{summary(x)$coefficients} for a \code{lm} object.
}
\note{
\code{sigma} -- The denominator is \emph{not} the number of
  observations, but rather the model's \emph{residual degrees of freedom}.

When calculating \emph{partial residuals}, the parameter estimates are
  \emph{not} re-calculated after removing one of the model terms.
}
\section{ANOVA tables}{

The \code{anova} method calculates the so-called \emph{Type III} test
statistics for a \code{bg_GLM} object. These standard ANOVA statistics
include: sum of squares, mean squares, degrees of freedom, F statistics, and
P-values. Additional statistics calculated are: \eqn{\eta^2}, partial
\eqn{\eta^2}, \eqn{\omega^2}, and partial \eqn{\omega^2} as measures of
\emph{effect size}.
}

\seealso{
\code{\link{GLM}}, \code{\link[car]{Anova}}
}
\author{
Christopher G. Watson, \email{cgwatson@bu.edu}
}
