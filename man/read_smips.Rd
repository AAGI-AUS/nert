% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read_smips.R
\name{read_smips}
\alias{read_smips}
\title{Read SMIPS COGs from TERN}
\usage{
read_smips(
  day,
  collection = "totalbucket",
  api_key = get_key(),
  max_tries = 3L,
  initial_delay = 1L
)
}
\arguments{
\item{day}{A date to query, \emph{e.g.}, \code{day = "2017-12-31"} or \code{day = as.Date("2017-12-01")}, both \code{Character} and \code{Date} classes are accepted.}

\item{collection}{A character vector of the \dQuote{SMIPS} data collection to
be queried:
\itemize{
\item SMindex: the \acronym{SMIPS} Soil Moisture Index (\emph{i.e.}, a number
between 0 and 1 that indicates how full the \acronym{SMIPS} bucket moisture
store is relative to its 90 cm capacity),
\item totalbucket: an estimate of the \emph{volumetric soil moisture (in mm)
from the \acronym{SMIPS} bucket moisture store},
Defaults to \dQuote{totalbucket}. Multiple \code{collections} are supported,
\emph{e.g.}, \code{collection = c("SMindex", "totalbucket")}.
}}

\item{api_key}{A \code{character} string containing your \acronym{API} key,
a random string provided to you by \acronym{TERN}, for the request.
Defaults to automatically detecting your key from your local .Renviron,
.Rprofile or similar.  Alternatively, you may directly provide your key as
a string here or use functionality like that from \CRANpkg{keyring}.  If
nothing is provided, you will be prompted on how to set up your \R session
so that it is auto-detected and a browser window will open at the
\acronym{TERN} website for you to request a key.}

\item{max_tries}{An integer \code{Integer} with the number of times to retry a
failed download before emitting an error message.  Defaults to 3.}

\item{initial_delay}{An \code{Integer} with the number of seconds to delay before
retrying the download.  This increases as the tries increment.  Defaults to
1.}
}
\value{
A \code{\link[terra:rast]{terra::rast()}} object.
}
\description{
Read Soil Moisture Integration and Prediction System (\acronym{SMIPS}) Cloud
Optimised Geotiff (\acronym{COG}) files from \acronym{TERN} in your \R
session.
}
\examples{
\dontshow{if (interactive()) withAutoprint(\{ # examplesIf}

r <- read_smips("2024-01-01")

# `tidyterra::autoplot` is re-exported for convenience
autoplot(r)
\dontshow{\}) # examplesIf}
}
\references{
\url{https://portal.tern.org.au/metadata/TERN/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0} and
\url{https://geonetwork.tern.org.au/geonetwork/srv/eng/catalog.search#/metadata/d1995ee8-53f0-4a7d-91c2-ad5e4a23e5e0}
}
\seealso{
Other COGs: 
\code{\link{read_asc}()}
}
\concept{COGs}
