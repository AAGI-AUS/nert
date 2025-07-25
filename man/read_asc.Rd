% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read_asc.R
\name{read_asc}
\alias{read_asc}
\title{Read ASC COGs from TERN}
\source{
\describe{
\item{ASC Data}{\url{https://data.tern.org.au/model-derived/slga/NationalMaps/SoilClassifications/ASC/90m/ASC_EV_C_P_AU_TRN_N.cog.tif}}
\item{Confusion Index}{\url{https://data.tern.org.au/model-derived/slga/NationalMaps/SoilClassifications/ASC/90m/ASC_CI_C_P_AU_TRN_N.cog.tif}}
}
}
\usage{
read_asc(
  confusion_index = FALSE,
  api_key = get_key(),
  max_tries = 3L,
  initial_delay = 1L
)
}
\arguments{
\item{confusion_index}{A \code{Boolean} value indicating whether to read the
Confusion Index (\code{TRUE}) or the estimated \acronym{ASC} value (\code{FALSE}).
Defaults to \code{FALSE} reading the \acronym{ASC} values.}

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
A  \code{\link[terra:rast]{terra::rast()}} object.
}
\description{
Read Australian Soil Classification (\acronym{ASC}) Cloud Optimised Geotiff
(\acronym{COG}) files from \acronym{TERN} in your \R session.  The data are
Australian Soil Classification Soil Order classes with quantified estimates
of mapping reliability at a 90 m resolution.  You can access the reliability
map using the \code{confusion_index} argument.
}
\examples{
\dontshow{if (interactive()) withAutoprint(\{ # examplesIf}

r <- read_asc()
r
\dontshow{\}) # examplesIf}
}
\references{
\url{https://portal.tern.org.au/metadata/TERN/15728dba-b49c-4da5-9073-13d8abe67d7c}
}
\seealso{
Other COGs: 
\code{\link{read_smips}()}
}
\concept{COGs}
