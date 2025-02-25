% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\name{cabins.tif}
\alias{cabins.tif}
\title{Cabin presence raster data}
\format{
A Geotiff file. Projected CRS: ETRS89 / UTM zone 33N.
\itemize{
\item{1:} {Presence of cabins}
\item{NA:} {No presence of cabins}
}
}
\source{
\url{https://register.geonorge.no/det-offentlige-kartgrunnlaget/n50-kartdata/ea192681-d039-42ec-b1bc-f3ce04c189ac}
}
\description{
Raster data indicating pixels with presence of tourist private cabins in Norway.
It corresponds to some specific building types (object_type = "Bygning",
byggtyp_nbr = c("161", "162", "163")) form the public N50 dataset.
The original data consisted of point vector data and were rasterized with 100m r
esolution, for the purpose of illustration here. The raster was cut for the
study area presented in the \link{oneimpact} package.
}
\examples{
(f <- system.file("raster/cabins.tif", package = "oneimpact"))
terra::rast(f)

}
