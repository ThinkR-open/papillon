usethis::use_build_ignore("devstuff_history.R")

# Documentation
usethis::use_readme_rmd()
usethis::use_vignette("bookdown-from-vignettes")

# Packages ----
usethis::use_pipe()
# devtools::install_github("ThinkR-open/attachment")
attachment::att_to_description(extra.suggests = c("pkgdown"))
# attachment::create_dependencies_file()

# Utils for dev
devtools::install(upgrade = "never")
# devtools::load_all()
devtools::check(vignettes = TRUE)
