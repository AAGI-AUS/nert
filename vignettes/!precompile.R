# vignettes that depend on Internet access need to be precompiled and take a
# while to run
library(knitr)
library(here)

devtools::install() # ensure we're building with the latest version of the package

knit(
  input = "vignettes/nert.Rmd.orig",
  output = "vignettes/nert.Rmd"
)

purl("vignettes/nert.Rmd.orig",
  output = "vignettes/nert.R"
)

knit(
  input = "vignettes/nert_for_agricultural_analytics.Rmd.orig",
  output = "vignettes/nert_for_agricultural_analytics.Rmd"
)

purl("vignettes/nert_for_agricultural_analytics.Rmd.orig",
  output = "vignettes/nert_for_agricultural_analytics.R"
)

# remove file path such that vignettes will build with figures
nert_replace <- readLines("vignettes/nert.Rmd")
nert_replace <- gsub("<img src=\"vignettes/", "<img src=\"", nert_replace)
nert_file_conn <- file("vignettes/nert.Rmd")
writeLines(nert_replace, nert_file_conn)
close(nert_file_conn)

ag_replace <- readLines("vignettes/nert_for_agricultural_analytics.Rmd")
ag_replace <- gsub("<img src=\"vignettes/", "<img src=\"", ag_replace)
ag_file_conn <- file("vignettes/nert_for_agricultural_analytics.Rmd")
writeLines(ag_replace, ag_file_conn)
close(ag_file_conn)

# build vignettes
library("devtools")
build_vignettes()

# move resource files to /docs
resources <-
  list.files("vignettes/", pattern = ".png$", full.names = TRUE)
file.copy(
  from = resources,
  to = here("doc"),
  overwrite = TRUE
)
