
<!-- badges: start -->

![cod cov](http://$SOME_BACKET.storage.googleapis.com/$PROJECT_NAME/codcov.svg)

[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![R build
status](https://github.com/ThinkR-open/chameleon/workflows/R-CMD-check/badge.svg)](https://github.com/ThinkR-open/chameleon/actions)
<!-- badges: end -->

<!-- README.md is generated from README.Rmd. Please edit that file -->

# chameleon

<!-- description: start -->

This is package {chameleon}: Build And Highlight Package Documentation
With Customized Templates.  
You are using version 0.0.1.9000. <!-- description: end -->

*Complete documentation in the {pkgdown} site:
<https://thinkr-open.github.io/chameleon/>*

## Installation

<!-- install: start -->

The list of dependencies required to install this package is:
attachment, bookdown, cli, crayon, desc, devtools, knitr, magrittr,
pkgdown, readr, remotes, rmarkdown, shiny, usethis, utils.

To install the package, you can run the following script

``` r
# install.packages("remotes")
remotes::install_github(repo = "Thinkr-open/chameleon")
```

<!-- install: end -->

## Examples

### Build a book from vignettes inside a package

You can use `create_book()` using your own template basis. By default,
it uses {bookdown} site template. You can use it to build your own.

``` r
template <- system.file("rstudio/templates/project/resources", package = "bookdown")
create_book(path = "inst/report", clean = TRUE,
            template = template)
```

Help users find your book with function `open_guide_function()`. This
adds function `open_guide()` inside your package that will open the
userguide (in HTML or PDF) on demand.

``` r
open_guide_function(path = "inst/report")
```

### Build a pkgdown site inside a package

You can use `build_pkgdown()` using your own template basis. By default,
it uses the {pkgdown} original template.  
To use your own template, it is better to create a R package with all
necessary files (See <https://github.com/tidyverse/tidytemplate> as an
example).

*You can then define your own `_pkgdown.yml` file that will call your
template when building the site:*

``` yaml
template:
  package: mypackagetemplate
```

``` r
chameleon::build_pkgdown(
  lazy = TRUE,
  yml = "/pah/to/your/yaml/_pkgdown.yml",
  favicon = "/path/to/your/favicon.ico",
  move = TRUE
)
```

Help users find your pkgdown website with function
`open_pkgdown_function()`. This adds function `open_pkgdown()` inside
your package that will open the site on demand. *This may make your
package not pass warnings in checks, but remember this is for internal
or private use. For public use, you can publish your pkgdown site
directly online.*

``` r
chameleon::open_pkgdown_function()
```

### Build a reference page

To award people hard working for open-source, it is always good to cite
their work. In order to add an informative page in your Shiny
applications for instance, you can create a html or markdown page
listing all package dependencies used.

``` r
chameleon::create_pkg_biblio_file(to = "html", out.dir = "inst")
# Can be included in a shiny app using 
shiny::includeHTML("bibliography.html")
# OR
chameleon::create_pkg_biblio_file(to = "markdown")
# Can be included in a shiny app using 
shiny::includeMarkdown("bibliography.md")
```

## To describe your package and how to install it

This can be useful to create your Readme for instance or to send the
instructions file for your clients to install your package.

``` r
path <- system.file("DESCRIPTION", package = "chameleon")
out.dir <- tempdir()
create_pkg_desc_file(path, source = c("archive"), to = "html")
```

``` r
# Use with results="asis" in a Rmd
shiny::includeHTML(file.path(out.dir, "pkg_description.html"))
```

## Create and update a custom README with installation instructions

  - `generate_readme()` uses {usethis} Readme template for packages and
    fill the installation instructions.  
  - This function can be run anytime during project development as it
    will only update the description and installation parts

<!-- end list -->

``` r
#usethis::use_readme_rmd
chameleon::generate_readme_rmd()
chameleon::generate_readme_rmd(parts = "description")
```

Please note that the ‘chameleon’ project is released with a [Contributor
Code of Conduct](CODE_OF_CONDUCT.md). By contributing to this project,
you agree to abide by its terms.
