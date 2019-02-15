usethis::use_build_ignore("devstuff_history.R")
usethis::use_gpl3_license("ThinkR")

# Documentation
usethis::use_readme_rmd()
usethis::use_vignette("aa-bookdown-from-vignettes")
usethis::use_vignette("ab-set-pkgdown-internal")

# Packages ----
usethis::use_pipe()
# devtools::install_github("ThinkR-open/attachment")
attachment::att_to_description()
# attachment::create_dependencies_file()

# Documentation ----
## _pkgdown
visualidentity::open_pkgdown_function(path = "docs")
visualidentity::build_pkgdown(
  lazy = TRUE,
  yml = system.file("pkgdown/_pkgdown.yml", package = "thinkridentity"),
  favicon = system.file("pkgdown/favicon.ico", package = "thinkridentity"),
  move = TRUE, clean_before = TRUE
)


visualidentity::open_pkgdown()

# Utils for dev
devtools::install(upgrade = "never")
# devtools::load_all()
devtools::check(vignettes = TRUE)

