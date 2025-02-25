#' @name zoi_functions
#'
#' @title Zone of Influence (ZoI) functions
#'
#' @description Computes the Zone of Influence (ZoI) decay functions.
#' The functions with different shapes represent multiple ways
#' the ZoI of an infrastructure or disturbance might affect a
#' given process in space, and the ZoI radius (`radius`)
#' controls how far this effect reaches. The rate
#' of decay of the different ZoI functions is parameterized based on
#' the ZoI radius -- e.g the slope of [oneimpact::linear_decay()] is defined
#' so that the function decreases to zero at the ZoI radius.
#' These functions can be used to transform arrays of (Euclidean)
#' distance values (in one dimension) or rasters of (Euclidean) distance
#' (in two dimensions) into ZoI values. The distances might represent
#' the distance to human infrastructure, sources of disturbance, or
#' more broadly any type of land use class or spatial variable.
#'
#' @details
#' A generic function [oneimpact::dist_decay()] can be used to compute
#' ZoI values according to functions with different shapes (argument `type`)
#' and radii (argument `radius`). Alternatively, there are spoecific functions
#' implemented for each ZoI shape.
#'
#' For the threshold function ([oneimpact::threshold_decay()]) and the linear decay
#' function ([oneimpact::linear_decay()]), the ZoI radius (`radius`) is the
#' distance `x` where the ZoI function value decreases to zero.
#' For the linear decay, this is done by setting
#' the slope of the linear function as `-intercept/radius`, where `intercept`
#' is the intercept of the linear function (here, the maximum value at `x = 0`).
#'
#' For non-vanishing functions that approach zero asymptotically
#' ([oneimpact::exp_decay()], [oneimpact::gaussian_decay()]), a certain limit value must be given to define
#' the ZoI radius -- so that the ZoI radius is defined as the distance `x` where the
#' ZoI function goes below this limit value. For these functions,
#' different parameters are available
#' for setting the relationship between the ZoI function value and the ZoI radius.
#'
#' Some functions have multiple possible names, for the sake of flexibility:
#' - [oneimpact::linear_decay()], [oneimpact::bartlett_decay()], and
#' [oneimpact::tent_decay()] are the same function;
#' - [oneimpact::threshold_decay()] and [oneimpact::step_decay()] are the same function;
#' - [oneimpact::gaussian_decay()] and [oneimpact::half_norm_decay()] are the same function.
#' Alternatively, [oneimpact::dist_decay()] can call all of them, given a
#' specified ZoI shape through the argument `type`.
#'
#' Other functions might be implemented.
#'
#' # Definitions
#'
#' Here are some formal definitions for the ZoI functions \eqn{\phi(d_i, r)},
#' where \eqn{d_i} is the distance to the feature \eqn{i} of an infrastructure or
#' source of disturbance and \eqn{r} is the ZoI radius:
#' - `threshold_decay`: the threshold or step decay function \eqn{\phi_{threshold}} is
#' positive and constant within the ZoI radius \eqn{r}, and null for \eqn{x \ge r}:
#' \deqn{
#' \phi_{threshold}(d_i, r_k) = c if d_i < r, 0 otherwise
#' }
#' where \eqn{c} is a constant value (by default = 1).
#' - `linear_decay`: the linear (or tent/Bartlett) decay function \eqn{\phi_{linear}}
#' decreases
#' linearly from a maximum value \eqn{b} (the intercept, by default = 1) to
#' zero when \eqn{x \ge r}:
#' \deqn{\phi_{linear}(d_i, r) = b - b/r if x < r, 0 otherwise}
#' - `exp_decay`: the exponential decay function \eqn{\phi_{exp}} decreases
#' exponentially from a maximum value \eqn{N} (by default = 1) with a rate
#' \eqn{\lambda}, which is defined by \eqn{r} and a ZoI limit value
#' \eqn{\phi_{lim}}, a small ZoI value below which the effect is considered negligible:
#' \deqn{\phi_{exp}(d_i, r, \phi_{lim}) = N exp(-\lambda d_i)}
#' with
#' \deqn{\lambda = ln(1/\phi_{lim}) / r}
#' In this context, the ZoI radius \eqn{r} is the distance beyond which
#' \eqn{\phi_{exp} < \phi_{lim}}.
#' - `gaussian_decay`: the Gaussian decay function \eqn{\phi_{Gauss}}
#' follows a Gaussian (half-normal) decay with maximum \eqn{N} (by default = 1)
#' and a decay rate \eqn{\lambda}
#' defined by \eqn{r} and a ZoI limit value
#' \eqn{\phi_{lim}}, a small ZoI value below which the effect is considered negligible:
#' \deqn{\phi_{Gauss}(d_i, r, \phi_{lim}) = N exp(-\lambda d_i^2)}
#' with
#' \deqn{\lambda = ln(1/\phi_{lim}) / (r^2)}
#' In this context, the ZoI radius \eqn{r} is the distance beyond which
#' \eqn{\phi_{exp} < \phi_{lim}}. Note that \eqn{\lambda} is defined differently
#' for the `gaussian_decay` and the `exp_decay` functions.
#'
#' @param x `[numeric,SpatRaster,RasterLayer]` \cr Euclidean distance from an infrastructure, source
#' of disturbance, or feature/class of interest. It can be a single value, an array
#' of values, or a raster object. It must not necessarily be an Euclidean distance,
#' but preferably it should be a distance measured in meters, to ease interpretation
#' (e.g. geodesic distance).
#'
#' @param radius `[numeric(1)]` \cr Zone of Influence (ZoI) radius,
#' the distance at which the ZoI vanishes or goes below a given minimum limit value
#' `zoi_limit`. See details.
#'
#' @param exp_decay_parms `[numeric(2)=c(1,0.01)]` \cr For the `exp_decay` function,
#' these are the exponential decay parameters c(N, lambda), where N is the maximum
#' value of the function (at `x = 0`)
#' and lambda is the decay parameter of the exponential function.
#' The value for `lambda` is only considered to draw the exponential decay function
#' if both `radius = NULL` and `half_life = NULL`.
#'
#' @param zoi_limit `[numeric(1)=0.05]` \cr For non-vanishing functions
#' (e.g. `exp_decay`, `gaussian_decay`), this value is used to set the relationship
#' between the ZoI radius and the decay functions:
#' `radius` is defined as the minimum distance `x` at which the ZoI assumes values
#' below `zoi_limit`. The default is 0.05. This parameter is used only
#' if `radius` is not `NULL`.
#'
#' @param origin `[numeric(1)=0]` \cr In which position (in 1 dimension) is located
#' the infrastructure or source of disturbance? Default is zero. For raster objects,
#' this parameter should be ignored.
#'
#' @param half_life `[numeric(1)=NULL]` \cr Half life of the exponential decay
#'  function, in meters. By definition, the half life is
#'  the distance where the exponential decay function reaches 0.5 of its
#'  maximum value. For the `exp_decay` function,
#'  if the ZoI radius parameter is null (`radius = NULL`), the value of the
#'  exponential half life (`half_life = log(2)/lambda`) can used to parameterize the
#'  exponential decay function.
#'
#' @param zoi_hl_ratio `[numeric(1)=NULL]` \cr For the `exp_decay` function,
#' if both the ZoI radius `radius` and `zoi_hl_ratio` are given and
#' `half_life` is `NULL`, this value is used
#' to set the ZoI radius (and `zoi_limit` is ignored).
#' `zoi_hl_ratio` is the ratio between the
#' ZoI radius value and the half life of the exponential function.
#' For instance, if `radius = 1200` and `zoi_hl_ratio = 6`, this means
#' `half_life` is 200. As a consequence, the exponential decay ZoI function
#' decreases to 0.5 at distance 200, and the ZoI radius = 1200
#' is defined as the distance
#' at which the ZoI decreases to 0.5**6 = 0.015625.
#'
#' @param oneside `[logical(1)=TRUE]` \cr If `FALSE`, negative distance values
#' are considered symmetrically and their transformation is always positive.
#' In general, this parameter does not make sense for raster objects.
#'
#' @param type `[character(1)="Gauss"]{"Gauss", "exp_decay", "bartlett",
#' "linear", "tent", "threshold", "step"}` \cr Type or shape of the decay distance.
#' \itemize{
#'   \item If `Gauss` or `half_norm`, the ZoI follows a half-normal shape: \cr
#'   `N_0 * exp(-lambda * (euclidean_distance^2))`. `N_0` and `lambda` are
#'   parameters to be defined -- see [oneimpact::zoi_functions()] for details.
#'   \item If `exp_decay`, the ZoI follows an exponential decay shape: \cr
#'   `N_0 * exp(-lambda * euclidean_distance)`. `N_0` and `lambda` are
#'   parameters to be defined -- see [oneimpact::zoi_functions()] for details.
#'   \item If `bartlett`, `linear_decay`, or `tent_decay`, the ZoI follows a
#'   linear decay shape within the ZoI radius (`radius`).
#'   \item If `threshold` or `step`, a constant influence is consider within the
#'   zone of influence radius (`radius`). All pixels closer than
#'   `radius` to infrastructure are considered as "under the influence" of
#'   the nearest feature, with a constant influence value defined by the
#'   `constant_influence` parameter, and all other pixels are assumed to have
#'   zero influence.
#' }
#'
#' @return The ZoI values for a given array of x values, or a raster
#' object delimiting the ZoI if x corresponds to the distance from
#' infrastructure or disturbance sources in 2 dimensional space.
#'
#' @example examples/zoi_functions_example.R
#'
#' @rdname zoi_functions
#' @export
dist_decay <- function(x, radius = NULL,
                       type = c("exp_decay", "gaussian_decay", "linear_decay",
                                "threshold_decay")[1],
                       zoi_limit = 0.05,
                       origin = 0,
                       oneside = TRUE,
                       ...) {

  if(type %in% c("exp_decay", "exp", "exponential")) {
    return(oneimpact::exp_decay(x = x, radius = radius, zoi_limit = zoi_limit,
                                origin = origin, oneside = oneside, ...))
  }

  if(type %in% c("Gauss", "gauss", "Gaussian", "gaussian", "gaussian_decay",
                 "normal", "Normal", "half_norm", "half_norm_decay")) {
    return(oneimpact::gaussian_decay(x = x, radius = radius, zoi_limit = zoi_limit,
                                     origin = origin, oneside = oneside, ...))
  }

  if(type %in% c("Bartlett", "bartlett", "bartlett_decay", "linear",
                 "linear_decay", "tent", "tent_decay")) {
    return(oneimpact::linear_decay(x = x, radius = radius,
                                   origin = origin, oneside = oneside, ...))
  }

  if(type %in% c("threshold", "threshold_decay", "step", "step_decay")) {
    return(oneimpact::threshold_decay(x = x, radius = radius,
                                      origin = origin, oneside = oneside, ...))
  }
}


#' @rdname zoi_functions
#' @export
exp_decay <- function(x, radius = NULL,
                      exp_decay_parms = c(1, 0.01),
                      zoi_limit = 0.05,
                      origin = 0,
                      half_life = NULL,
                      zoi_hl_ratio = NULL,
                      oneside = TRUE) {

  # define lambda depending on the input parameter
  if(!is.null(radius)) {

    if(is.null(zoi_hl_ratio)) {
      lambda <- log(1/zoi_limit) / radius
    } else {
      half_life <- radius/zoi_hl_ratio
      lambda <- log(2)/half_life
    }

  } else {

    if(!is.null(half_life)) {
      lambda <- log(2)/half_life
    } else {
      lambda <- exp_decay_parms[2]
    }
  }

  # return function
  if(oneside) func <- identity else func <- abs

  exp_decay_parms[1] * exp(- lambda * func(x - origin))
}

#' @param constant_influence `[numeric(1)=1]` \cr Constant value of the
#' threshold (or step) function within the Zone of Influence. Default is 1.
#'
#' @rdname zoi_functions
#' @export
threshold_decay <- function(x, radius, constant_influence = 1, origin = 0, oneside = TRUE) {
  UseMethod("threshold_decay")
}

#' @name zoi_functions
#' @export
threshold_decay.numeric <- function(x, radius, constant_influence = 1, origin = 0, oneside = TRUE) {
  if(oneside) func <- identity else func <- abs
  ifelse(func(x - origin) < radius, constant_influence, 0)
}

# possibly have that for RasterLayer as well

#' @name zoi_functions
#' @export
threshold_decay.SpatRaster <- function(x, radius, constant_influence = 1, origin = 0, oneside = TRUE) {
  if(oneside) func <- identity else func <- abs
  ifel(func(x - origin) < radius, constant_influence, 0)
}

#' @rdname zoi_functions
#' @export
step_decay <- threshold_decay

#' @param intercept `[numeric(1)=1]` For the Bartlett (linear or tent decay) function,
#' `intercept` is the maximum value of the function (at `x = 0`).
#'
#' @rdname zoi_functions
#' @export
bartlett_decay <- function(x, radius, intercept = 1, origin = 0, oneside = TRUE) {
  UseMethod("bartlett_decay")
}

#' @rdname zoi_functions
#' @export
bartlett_decay.numeric <- function(x, radius, intercept = 1, origin = 0, oneside = TRUE) {
  if(oneside) func <- identity else func <- abs
  beta = -intercept/radius
  ifelse(func(x - origin) < radius, intercept + beta * func(x - origin), 0)
}

#' @rdname zoi_functions
#' @export
bartlett_decay.SpatRaster <- function(x, radius, intercept = 1, origin = 0, oneside = TRUE) {
  if(oneside) func <- identity else func <- abs
  beta = -intercept/radius
  ifel(func(x - origin) < radius, intercept + beta * func(x - origin), 0)
}

#' @rdname zoi_functions
#' @export
tent_decay <- bartlett_decay

#' @rdname zoi_functions
#' @export
linear_decay <- bartlett_decay

#' @param sigma `[numeric(1)=NULL]` \cr Standard deviation of the Gaussian
#' function. It related to the Gaussian decay rate \eqn{\lambda} as
#' `lambda = 1/(2*sigma^2)`. Only considered to compute the ZoI
#' for the `gaussian_decay` function when the ZoI radius parameter is null
#' (`radius = NULL`).
#'
#' @param hnorm_decay_parms `[numeric(2)=c(1,0.01)]` \cr For the `gaussian_decay` function,
#' these are the guassian decay parameters c(N, lambda), where N is the maximum
#' value of the function (at `x = 0`)
#' and lambda is the decay parameter of the Gaussian function.
#' The value for `lambda` is only considered to draw the Gaussian decay function
#' if both `radius = NULL` and `sigma = NULL`.
#'
#' @rdname zoi_functions
#' @export
gaussian_decay <- function(x, radius = NULL,
                           hnorm_decay_parms = c(1, 0.01),
                           sigma = NULL,
                           zoi_limit = 0.05,
                           origin = 0, ...) {

  if(!is.null(radius)) {
    lambda = log(1/zoi_limit) / (radius**2)
  } else {
    if(!is.null(sigma)) {
      lambda = 1/(2*sigma**2)
    } else {
      lambda <- hnorm_decay_parms[2]
    }

  }

  hnorm_decay_parms[1] * exp(- lambda * (x - origin)**2)
}

#' @rdname zoi_functions
#' @export
half_norm_decay <- gaussian_decay
