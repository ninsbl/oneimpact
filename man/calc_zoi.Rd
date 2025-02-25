% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/calc_zoi.R
\name{calc_zoi}
\alias{calc_zoi}
\title{Calculates the zone of influence from the nearest feature
and the cumulative zone of influence of multiple features}
\usage{
calc_zoi(
  x,
  zoi_metric = c("all", "nearest", "cumulative")[1],
  where = c("R", "GRASS")[1],
  ...
)
}
\arguments{
\item{x}{\verb{[RasterLayer,SpatRaster]} \cr Raster representing locations of features,
preferentially with value 1 (or any other positive value) where the features
are located and NA elsewhere. Alternatively, \code{x} might be a binary (dummy)
spatial variable representing the presence of linear or area features, with
NA/no-data as background.
\code{x} can be a \code{RasterLayer} from \link{raster} package or a \link{SpatRaster} from
\link{terra} package. If \code{where = "GRASS"}, \code{x} must be a string corresponding
to the name of the input map within a GRASS GIS location and mapset.
Maps without NA as background might be prepared as input for \code{calc_zoi_nearest}
through \href{https://rspatial.org/terra/pkg/4-algebra.html}{raster algebra} in R
and e.g. through the use of the module
\href{https://grass.osgeo.org/grass80/manuals/r.null.html}{\code{r.null}} in GRASS GIS.}

\item{zoi_metric}{\verb{[character(1)="all"]\{"all", "nearest", "cumulative"\}} \cr
Which metric of zone of influence should be computed. Either \code{"all"}, \code{"nearest"},
or \code{"cumulative"}.}

\item{where}{\verb{[character(1)="R"]\{"R", "GRASS"\}} \cr Where should the
computation be done? Default is \code{"R"}. If \code{where = "GRASS"}, the R session
must be linked to an open GRASS GIS session in a specific location and mapset.}

\item{...}{\cr Adittional parameters passed to \code{\link[terra:distance]{terra::distance()}}
or to the ZoI functions (see \code{\link[=zoi_functions]{zoi_functions()}}) when the
calculations are performed in R.
No additional parameters implemented for computation in GRASS GIS.}
}
\value{
A RasterBrick with de distance to the nearest feature and the densities for all scales selected.
}
\description{
This function takes in a raster with locations of infrastructure and calculates (1)
a raster representing the distance from each pixel to the neareast feature and (2)
a raster (or set of rasters, in case there is more the one value for \code{scale})
representing the density of features in space (through a spatial filter/neighborhood analysis).
The neighborhood analysis is done with the \code{\link[raster:focal]{raster::focal()}} function.
}
\details{
The neighborhood analysis can be done with different methods. The default is a Gaussian filter
(\code{type_density = "Gauss"}), in which case scale corresponds to the sigma paramater of the Gaussian
filter. If \code{type_density = "circle"} or \code{type_density = "rectangle"}, the scale corresponds to the
radius of the circle or width of the rectangle, respectively. See \code{\link[raster:focalWeight]{raster::focalWeight()}} for more
details.

TO IMPROVE2: do the same in communication with GRASS GIS.
}
\examples{
library(terra)
}
\seealso{
\code{\link[=calc_zoi_nearest]{calc_zoi_nearest()}}, \code{\link[=calc_zoi_cumulative]{calc_zoi_cumulative()}}
}
