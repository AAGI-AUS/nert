# vignettes that depend on Internet access need to be precompiled and take a
# while to run
library(knitr)
library(here)
library(devtools)

install() # ensure we're building with the latest version of the package


## Vignette - nert.Rmd (intro to nert vignette)
knit(input = "vignettes/nert.Rmd.orig", output = "vignettes/nert.Rmd")
purl("vignettes/nert.Rmd.orig", output = "vignettes/nert.R")

# remove file path such that vignettes will build with figures
nert_replace <- readLines("vignettes/nert.Rmd")
nert_replace <- gsub("<img src=\"vignettes/", "<img src=\"", nert_replace)
nert_file_conn <- file("vignettes/nert.Rmd")
writeLines(nert_replace, nert_file_conn)
close(nert_file_conn)


## Vignette - nert_for_agricultural_analytics.Rmd (analysis vignette)
knit(
  input = "vignettes/nert_for_agricultural_analytics.Rmd.orig",
  output = "vignettes/nert_for_agricultural_analytics.Rmd"
)
purl(
  "vignettes/nert_for_agricultural_analytics.Rmd.orig",
  output = "vignettes/nert_for_agricultural_analytics.R"
)

# remove file path such that vignettes will build with figures
ag_replace <- readLines("vignettes/nert_for_agricultural_analytics.Rmd")
ag_replace <- gsub("<img src=\"vignettes/", "<img src=\"", ag_replace)
ag_file_conn <- file("vignettes/nert_for_agricultural_analytics.Rmd")
writeLines(ag_replace, ag_file_conn)
close(ag_file_conn)


## Vignette - collect_tern_data.Rmd (using the aggregator function)
knit(
  input = "vignettes/collect_tern_data.Rmd.orig",
  output = "vignettes/collect_tern_data.Rmd"
)
purl(
  "vignettes/collect_tern_data.Rmd.orig",
  output = "vignettes/collect_tern_data-vignette.R"
)

# remove file path such that vignettes will build with figures
ctd_replace <- readLines("vignettes/collect_tern_data.Rmd")
ctd_replace <- gsub("<img src=\"vignettes/", "<img src=\"", ctd_replace)
ctd_file_conn <- file("vignettes/collect_tern_data.Rmd")
writeLines(ctd_replace, ctd_file_conn)
close(ctd_file_conn)


build_vignettes()

# move resource files to /doc
resources <- list.files("vignettes/", pattern = ".png$", full.names = TRUE)
file.copy(from = resources, to = here("doc"), overwrite = TRUE)
