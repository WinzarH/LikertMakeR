## send to https://winzarh.github.io/LikertMakeR/

## 1. Clean and rebuild attributes
Rcpp::compileAttributes()

# 2. Re-generate Rd files, NAMESPACE, etc.
roxygen2::roxygenise()

# 3. (Optional but good idea) Clean compiled objects
unlink("src/*.o")
unlink("src/*.so")
unlink("src/*.dll")
unlink("src/RcppExports.cpp")
unlink("R/RcppExports.R")

Rcpp::compileAttributes()

# .rs.restartR()
#
# unlink(file.path(.libPaths()[1], "00LOCK-LikertMakeR"), recursive = TRUE, force = TRUE)

# devtools::install(upgrade = "never")

## Then rebuild from scratch
# devtools::install(upgrade = "always")

# devtools::install()

## clear any stale namespace bindings
.rs.restartR()

"LikertMakeR" %in% loadedNamespaces()   # should be FALSE

unlink(file.path(.libPaths()[1], "00LOCK-LikertMakeR"), recursive = TRUE, force = TRUE)
unlink(file.path(.libPaths()[1], "LikertMakeR"),          recursive = TRUE, force = TRUE)


getNamespaceExports("LikertMakeR")
# Look for: "lcor_C_randomised"

# pkgdown::clean_site(force = TRUE)

# pkgdown::build_favicons(overwrite = TRUE)

# pkgdown::build_favicons()
# optional but helpful if you have compiled code

devtools::clean_dll()

# install into your active library
devtools::install(upgrade = "never", force = TRUE)


pkgdown::build_site()


# 1) Make sure it's not loaded
"LikertMakeR" %in% loadedNamespaces()   # should be FALSE

# 2) Install to your user library (once, so deploy can load it)
# devtools::install(upgrade = "never")
devtools::install()

# sanity check:
system.file(package = "LikertMakeR")    # should print a path

# 3) Deploy
pkgdown::deploy_to_branch()

