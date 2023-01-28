usethis::use_build_ignore("devstuff_history.R")
usethis::use_gpl3_license("ThinkR")
usethis::use_git_ignore("*.Rproj")
usethis::use_git_ignore(".Rhistory")
usethis::use_code_of_conduct()

# Documentation
usethis::use_readme_rmd()
papillon::generate_readme_rmd(parts = "description")
usethis::use_vignette("aa-bookdown-from-vignettes")
usethis::use_vignette("ab-set-pkgdown-internal")
usethis::use_vignette("ac-create-bibliography-file")
usethis::use_vignette("ad-create-description-file")

# Packages ----
usethis::use_pipe()
# devtools::install_github("ThinkR-open/attachment")
attachment::att_amend_desc(
  pkg_ignore = c("devtools", "remotes"), 
  extra.suggests = c("devtools", "remotes"))
# attachment::create_dependencies_file()

# Documentation ----
## _pkgdown
# install.packages("thinkrtemplate", repos = 'https://thinkr-open.r-universe.dev')
papillon::open_pkgdown_function(path = "docs")
papillon::build_pkgdown(
  lazy = TRUE,
  yml = system.file("pkgdown/_pkgdown.yml", package = "thinkridentity"),
  favicon = system.file("pkgdown/favicon.ico", package = "thinkridentity"),
  move = TRUE, clean_before = TRUE
)

## Remove this one from git
usethis::use_git_ignore("docs")
usethis::use_git_ignore("inst/docs")

# _deploy pkgdown on Travis

# Bibliography file
papillon::create_pkg_biblio_file(to = "html", out.dir = "inst", edit = FALSE)

# Utils for dev
devtools::install(upgrade = "never")
# devtools::load_all()
devtools::check(vignettes = TRUE)

# CI
usethis::git_default_branch_rename()
usethis::use_github_action_check_standard()
usethis::use_github_action("pkgdown")
usethis::use_github_action("test-coverage")
usethis::use_coverage()
usethis::use_build_ignore("_pkgdown.yml")
usethis::use_package_doc()
usethis::use_code_of_conduct("codeofconduct@thinkr.fr")
