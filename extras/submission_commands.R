

# devtools::lint()

Rcpp::compileAttributes()

devtools::document()
# devtools::clean_dll()

# Sys.setenv(R_MARKDOWN_QUARTO = 0)
devtools::check()

devtools::build()

# devtools::check()
devtools::check_win_devel()
rhub::rhub_check()






unlink("LikertMakeR.Rcheck", recursive = TRUE)
devtools::document()
devtools::check()
devtools::check_win_devel()






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



# tar <- pkgbuild::build()
# rcmdcheck::rcmdcheck(tar, args = "--as-cran")

# devtools::clean_dll()
# devtools::document()
# devtools::build()
# devtools::check()

# devtools::clean_dll()
devtools::document()
devtools::build()
devtools::check()


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




