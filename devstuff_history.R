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

## __ deploy on rsconnect
usethis::use_git_ignore("docs/rsconnect")
usethis::use_git_ignore("inst/docs/rsconnect")
usethis::use_git_ignore("rsconnect")

origwd <- setwd("inst/docs/")
origwd <- setwd("docs")
account_name <- rstudioapi::showPrompt("Rsconnect account", "Please enter your username:", "name")
account_server <- rstudioapi::showPrompt("Rsconnect server", "Please enter your server name:", "1.1.1.1")
rsconnect::deployApp(
  ".",                       # the directory containing the content
  appFiles = list.files(".", recursive = TRUE), # the list of files to include as dependencies (all of them)
  appPrimaryDoc = "index.html",                 # the primary file
  appName = "visualidentity",                   # name of the endpoint (unique to your account on Connect)
  appTitle = "visualidentity",                  # display name for the content
  account = account_name,                # your Connect username
  server = account_server                    # the Connect server, see rsconnect::accounts()
)
setwd(origwd)

# Utils for dev
devtools::install(upgrade = "never")
# devtools::load_all()
devtools::check(vignettes = TRUE)

