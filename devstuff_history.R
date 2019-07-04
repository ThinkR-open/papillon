usethis::use_build_ignore("devstuff_history.R")
usethis::use_gpl3_license("ThinkR")
usethis::use_git_ignore("*.Rproj")
usethis::use_git_ignore(".Rhistory")

# Documentation
usethis::use_readme_rmd()
usethis::use_vignette("aa-bookdown-from-vignettes")
usethis::use_vignette("ab-set-pkgdown-internal")
usethis::use_vignette("ac-create-bibliography-file")
usethis::use_vignette("ad-create-description-file")

# Packages ----
usethis::use_pipe()
# devtools::install_github("ThinkR-open/attachment")
attachment::att_to_description()
# attachment::create_dependencies_file()

# Documentation ----
## _pkgdown
chameleon::open_pkgdown_function(path = "docs")
chameleon::build_pkgdown(
  lazy = TRUE,
  yml = system.file("pkgdown/_pkgdown.yml", package = "thinkridentity"),
  favicon = system.file("pkgdown/favicon.ico", package = "thinkridentity"),
  move = TRUE, clean_before = TRUE
)

## Remove this one from git
usethis::use_git_ignore("docs")
usethis::use_git_ignore("inst/docs")

## __ deploy {pkgdown} on rsconnect
usethis::use_git_ignore("docs/rsconnect")
usethis::use_git_ignore("inst/docs/rsconnect")
usethis::use_git_ignore("rsconnect")

rsconnect::accounts()
account_name <- rstudioapi::showPrompt("Rsconnect account", "Please enter your username:", "name")
account_server <- rstudioapi::showPrompt("Rsconnect server", "Please enter your server name:", "1.1.1.1")
origwd <- setwd("inst/docs")
rsconnect::deployApp(
  ".",                       # the directory containing the content
  appFiles = list.files(".", recursive = TRUE), # the list of files to include as dependencies (all of them)
  appPrimaryDoc = "index.html",                 # the primary file
  appName = "chameleon",                   # name of the endpoint (unique to your account on Connect)
  appTitle = "chameleon",                  # display name for the content
  account = account_name,                # your Connect username
  server = account_server                    # the Connect server, see rsconnect::accounts()
)
setwd(origwd)

# _deploy pkgdown on Travis

# Bibliography file
chameleon::create_pkg_biblio_file(to = "html", out.dir = "inst", edit = FALSE)

# Utils for dev
devtools::install(upgrade = "never")
# devtools::load_all()
devtools::check(vignettes = TRUE)

# CI
usethis::use_travis()
