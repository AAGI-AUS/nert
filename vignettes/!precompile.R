# vignettes that depend on Internet access need to be precompiled and take a
# while to run
library(knitr)
knit(
  input = "vignettes/nert.Rmd.orig",
  output = "vignettes/nert.Rmd"
)

knit(
  input = "vignettes/nert_for_agricultural_analytics.Rmd.orig",
  input = "vingettes/nert_for_agricultural_analytics.Rmd"
)

# remove file path such that vignettes will build with figures
replace <- readLines("vignettes/nert.Rmd")
replace <- gsub("<img src=\"vignettes/", "<img src=\"", replace)
fileConn <- file("vignettes/nert.Rmd")
writeLines(replace, fileConn)
close(fileConn)

replace <- readLines("vignettes/nert_for_agricultural_analytics.Rmd")
replace <- gsub("<img src=\"vignettes/", "<img src=\"", replace)
fileConn <- file("vignettes/nert_for_agricultural_analytics.Rmd")
writeLines(replace, fileConn)
close(fileConn)

# build vignettes
library("devtools")
build_vignettes()

# move resource files to /docs
resources <-
  list.files("vignettes/", pattern = ".png$", full.names = TRUE)
file.copy(
  from = resources,
  to = "doc",
  overwrite = TRUE
)
