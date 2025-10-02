
## 10.32614/CRAN.package.LikertMakeR

usethis::use_build_ignore(c(
  ".github",
  "cran-comments.md",
  "_pkgdown.yml",
  "docs",
  "pkgdown",
  "extras",
  "CRAN-SUBMISSION",
  "Meta"
))

usethis::use_git_ignore(c(
  ".Rproj.user",
  ".Rhistory",
  ".RData",
  ".DS_Store"
))

usethis::use_git_ignore(c(
  "docs",
  "*.tar.gz",
  "src/*.o",
  "src/*.so",
  "*.dll"
), directory = ".")


Rcpp::compileAttributes()

devtools::document()
devtools::clean_dll()
devtools::check()
devtools::build()

# devtools::check()
devtools::check_win_devel()
rhub::rhub_check()





Sys.which("Rcmd.exe")


roxygen2::roxygenise()

devtools::test()
# devtools::show_news()
devtools::run_examples()



styler::style_pkg()

# Run a spell check
devtools::spell_check()

# auto-adds current false positives to inst/WORDLIST
spelling::update_wordlist()

#
# spelling::spell_check_package(vignettes = FALSE)

# fs::dir_info(".", recurse = TRUE) |>
#   dplyr::arrange(modification_time) |>
#   tail(10)



# Run a full package check
devtools::check(clean = TRUE)

tar <- pkgbuild::build()
rcmdcheck::rcmdcheck(tar, args = "--as-cran")

# devtools::clean_dll()
# devtools::document()
# devtools::build(clean = TRUE)
# devtools::check()

devtools::clean_dll()
devtools::document()
devtools::build(clean = TRUE)
# devtools::check()


# usethis::use_release_issue()

usethis::use_cran_comments(open = rlang::is_interactive())

## Clean all artifacts
# devtools::clean_vignettes()
# unlink("inst/doc", recursive = TRUE)
# unlink("Meta", recursive = TRUE)


# devtools::clean_vignettes()
# devtools::build_vignettes()


# vignette(package = "LikertMakeR")
#
# usethis::use_build_ignore(c("_pkgdown.yml", "docs", "pkgdown", "extras"))


devtools::check_win_devel()


# rhub::rhub_setup(overwrite = FALSE)

rhub::rhub_setup()

rhub::rhub_doctor()

rhub::rhub_platforms()

rhub::rhub_check()

# rhub::check(platforms = "debian-clang-devel")

# rhub::rhub_check(gh_url = "https://github.com/winzarh/LikertMakeR")



devtools::install()

devtools::load_all()





#-------------
# Release to CRAN ####
#-------------
devtools::release()




