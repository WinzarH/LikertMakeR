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

# Then rebuild from scratch
devtools::install(upgrade = "never")

# clear any stale namespace bindings
.rs.restartR()


getNamespaceExports("LikertMakeR")
# Look for: "lcor_C_randomised"

# pkgdown::clean_site(force = TRUE)

pkgdown::build_favicons(overwrite = TRUE)

pkgdown::build_site()

# Replace with your real details
system('git config --global user.name "Hume Winzar"')
system('git config --global user.email "winzar@gmail.com"')

system("git config --global --list")

pkgdown::deploy_to_branch()
