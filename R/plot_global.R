#' Plot global graph measures across densities
#'
#' Create a faceted line plot of global graph measures across a range of graph
#' densities, calculated from a list of \code{brainGraphList} objects. This
#' requires that the variables of interest are graph-level attributes of the
#' input graphs.
#'
#' You can choose to insert a dashed vertical line at a specific
#' density/threshold of interest, rename the variable levels (which become the
#' facet titles), exclude variables, and include a \code{brainGraph_permute}
#' object of permutation data to add asterisks indicating significant group
#' differences.
#'
#' @inheritParams Random Graphs
#' @param xvar A character string indicating whether the variable of
#' interest is \dQuote{density} or \dQuote{threshold} (e.g. with DTI data)
#' @param vline Numeric of length 1 specifying the x-intercept if you would like
#'   to plot a vertical dashed line (e.g., if there is a particular density of
#'   interest). Default: \code{NULL}
#' @param level.names Character vector of variable names, which are displayed as
#'   facet labels. If you do not want to change them, specify \code{NULL}. By
#'   default, they are changed to pre-set values.
#' @param exclude Character vector of variables to exclude. Default: \code{NULL}
#' @param perms A \code{\link{data.table}} of permutation group differences
#' @param alt Character vector of alternative hypotheses; required if
#'   \emph{perms} is provided, but defaults to \dQuote{two.sided} for all
#'   variables
#' @export
#'
#' @return Either a \code{trellis} or \code{ggplot} object
#' @author Christopher G. Watson, \email{cgwatson@@bu.edu}

plot_global <- function(g.list, xvar=c('density', 'threshold'), vline=NULL,
                        level.names='default', exclude=NULL, perms=NULL, alt='two.sided') {
  sig <- trend <- yloc <- value <- variable <- threshold <- panel.num <- NULL

  # Check if components are 'brainGraphList' objects
  matches <- vapply(g.list, is.brainGraphList, logical(1L))
  if (any(!matches)) stop("Input must be a list of 'brainGraphList' objects.")

  sID <- getOption('bg.subject_id')
  gID <- getOption('bg.group')
  DT <- rbindlist(lapply(g.list, graph_attr_dt), use.names=TRUE)
  idvars <- c('atlas', 'modality', 'weighting', sID, gID, 'threshold', 'density')
  idvars <- idvars[which(hasName(DT, idvars))]
  DT.m <- melt(DT, id.vars=idvars)
  DT.m <- droplevels(DT.m[!variable %in% exclude])

  # Add asterisks if a data.table of permutation values is provided
  if (!is.null(perms)) {
    DT.m[, c('sig', 'trend') := '']
    DT.m[, yloc := extendrange(value)[1L], by=variable]
    vars <- setdiff(names(perms$DT), 'densities')
    nvars <- length(vars)
    if (length(alt) < nvars) alt <- rep_len(alt, nvars)
    for (i in seq_along(vars)) {
      dt <- plot(perms, measure=vars[i], alternative=alt[i])[[1L]]$data[variable == 'obs.diff']
      DT.m[variable == vars[i], sig := dt$sig]
      DT.m[variable == vars[i], trend := dt$trend]
      DT.m[variable == vars[i], yloc := dt$yloc]
    }
  }

  if (!is.null(level.names)) {
    if (level.names == 'default') level.names <- rename_levels(DT.m)
    nvars <- DT.m[, nlevels(variable)]
    if (length(level.names) < nvars) level.names <- rep_len(level.names, nvars)
    levels(DT.m$variable) <- level.names
  }

  xvar <- match.arg(xvar)
  # 'base' plotting
  if (!requireNamespace('ggplot2', quietly=TRUE)) {
    grps <- DT.m[, levels(as.factor(get(gID)))]
    DT.m[, panel.num := as.numeric(variable)]
    if (!is.null(vline)) {
      if (is.null(perms)) {
        panelfun <- function(x, y, groups, ...) {
          panel.abline(v=vline, lty=2, col='grey60')
          panel.xyplot(x, y, groups, ...)
        }
      } else {
        panelfun <- function(x, y, groups, ...) {
          panel.num <- NULL
          panel.abline(v=vline, lty=2, col='grey60')
          panel.xyplot(x, y, groups, ...)
          DT.m[panel.num == panel.number() & sig == '*',
               panel.text(density, yloc, labels='*', col=plot.cols[1L])]
          DT.m[panel.num == panel.number() & trend == '*',
               panel.text(density, yloc, labels='*', col=plot.cols[2L])]
        }
      }
    } else {
      if (is.null(perms)) {
        panelfun <- function(x, y, groups, ...) {
          panel.xyplot(x, y, groups, ...)
        }
      } else {
        panelfun <- function(x, y, groups, ...) {
          panel.num <- NULL
          panel.xyplot(x, y, groups, ...)
          DT.m[panel.num == panel.number() & sig == '*',
               panel.text(density, yloc, labels='*', col=plot.cols[1L])]
          DT.m[panel.num == panel.number() & trend == '*',
               panel.text(density, yloc, labels='*', col=plot.cols[2L])]
        }
      }
    }
    p <- xyplot(value ~ get(xvar) | variable, data=DT.m, groups=get(gID), type='l',
                xlab=xvar, panel=panelfun, scales=list(y=list(relation='free')),
                auto.key=list(space='bottom', title=gID, cex.title=1, columns=length(grps),
                              lines=TRUE, points=FALSE))

  # 'ggplot2' plotting
  } else {
    p <- switch(xvar,
                density=ggplot2::ggplot(DT.m, ggplot2::aes(x=density, y=value, col=get(gID))),
                threshold=ggplot2::ggplot(DT.m, ggplot2::aes(x=threshold, y=value, col=get(gID))) + ggplot2::scale_x_reverse())

    if (hasName(DT.m, sID)) {
      p <- p + ggplot2::stat_smooth(method='gam', formula=y~s(x))
    } else {
      p <- p + ggplot2::geom_line()
    }
    p <- p +
      ggplot2::facet_wrap(~ variable, scales='free_y') +
      ggplot2::theme(legend.position='bottom', axis.text.x=ggplot2::element_text(angle=45, hjust=1))

    if (!is.null(vline)) p <- p + ggplot2::geom_vline(xintercept=vline, lty=2, col='grey60')
    if (!is.null(perms)) {
      p <- p +
        ggplot2::geom_text(ggplot2::aes(y=yloc, label=sig), col='red', size=3) +
        ggplot2::geom_text(ggplot2::aes(y=yloc, label=trend), col='blue', size=3)
    }
  }
  return(p)
}

#' Rename the levels of global metrics in a data.table
#'
#' @param DT A \code{data.table}
#' @return The levels of the \code{variable} column after being changed
#' @keywords internal
rename_levels <- function(DT) {
  orig <- c('Lp', 'E.global', 'E.local', 'mod', 'diameter', 'transitivity', 'num.hubs')
  orig <- c(orig, paste0(orig, '.wt'))
  orig <- c(orig, 'Cp', 'max.comp', 'num.tri', 'asymm', 'spatial.dist', 'vulnerability',
            'strength', paste0('assort', c('', '.lobe.hemi', '.lobe', '.class', '.network')))
  abbr <- c('Char. path length', 'Global eff.', 'Local eff.', 'Modularity',
            'Diameter', 'Transitivity', '# of hubs')
  abbr <- c(abbr, paste(abbr, '(wt)'))
  abbr <- c(abbr, 'Clustering coeff.', 'Max. conn. comp.', '# of triangles', 'Asymmetry index',
            'Edge distance', 'Vulnerability', 'Strength',
            paste(c('Degree', 'Lobe & hemi', 'Lobe', 'Class', 'Network'), 'assort.'))
  inds <- match(levels(DT$variable), orig)
  orig <- orig[inds]
  abbr <- abbr[inds]
  orig <- paste0('^', orig, '$')
  out <- diag(mapply(sub, orig, abbr, MoreArgs=list(x=levels(DT$variable))))
  return(out)
}
