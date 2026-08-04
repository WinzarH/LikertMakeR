## send to https://winzarh.github.io/LikertMakeR/

library(goodpractice)
gp()


## 1. Clean and rebuild attributes
Rcpp::compileAttributes()

# 2. Re-generate Rd files, NAMESPACE, etc.
roxygen2::roxygenise()


"LikertMakeR" %in% loadedNamespaces() # should be FALSE

getNamespaceExports("LikertMakeR")
# Look for: "lcor_C_randomised"


urlchecker::url_check()

# updates DESCRIPTION/R/Rd; still manually fix Rmd/Bib if needed
urlchecker::url_update()


devtools::clean_dll()


devtools::document()


devtools::check()

# rhub::rhub_setup(overwrite = TRUE)

# 0) restart R

# 1) Make sure it's not loaded
"LikertMakeR" %in% loadedNamespaces() # should be FALSE

# 2) Install to your user library (once, so deploy can load it)
# devtools::install(upgrade = "never")
devtools::install()

# 3)
## to completely rebuild site if change in structure or names of articles
# pkgdown::build_site()

## regenerate everything from scratch
# unlink(c("docs", "_pkgdown"), recursive = TRUE)

pkgdown::build_site(
  preview = TRUE,
  lazy = FALSE
)


# sanity check:
system.file(package = "LikertMakeR") # should print a path

# 3) Deploy
pkgdown::deploy_to_branch()



