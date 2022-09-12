#' Create and update a custom README.Rmd with installation instructions
#'
#' @param base_path Path of the package to generate Readme from
#' @param parts Parts to modify in the Readme: c("description", "installation")
#' @param edit Logical. Whether to open README.Rmd 
#'
#' @inheritParams create_pkg_desc_file
#'
#' @return A README.Rmd file
#' @export
#'
#' @examples
#' \dontrun{
#' generate_readme_rmd()
#' }
generate_readme_rmd <- function(
  base_path = usethis::proj_get(),
  parts = c("description", "installation"),
  source = c("archive", "github", "git"),
  edit = TRUE,
  url
) {
  parts <- match.arg(parts, c("description", "installation"), several.ok = TRUE)
  source <- match.arg(source, c("archive", "github", "git"), several.ok = FALSE)

  # get project information
  readme_path <- file.path(base_path, "README.Rmd")
  desc <- desc::description$new(base_path)
  data <- as.list(desc$get(desc$fields()))

  # data <- project_data()
  data$Rmd <- TRUE
  
  # Create skeleton
  if (!file.exists(readme_path)) {
    usethis::use_template("package-README", "README.Rmd", data = data, ignore = TRUE, 
                          open = FALSE, package = "papillon")
  }
  
  # Modify skeleton
  ## Read Readme
  readme <- readLines(file.path(base_path, "README.Rmd"))
  
  ## Create content with papillon
  cham_desc_file <- papillon::create_pkg_desc_file(source = source, to = "raw", edit = FALSE)
  cham_desc <- readLines(cham_desc_file)
  
  # Modify content
  if ("description" %in% parts) {
    readme_description <- c(grep("<!-- description: start -->", readme),
                            grep("<!-- description: end -->", readme))
    if (length(readme_description) != 2) {stop("Readme lacks tags: <!-- description: start --> and/or <!-- description: end -->")}
    
    cham_description <- c(grep("<!-- description: start -->", cham_desc) + 1,
                          grep("<!-- description: end -->", cham_desc) - 1)
    
    readme <- c(readme[1:readme_description[1]],
                cham_desc[cham_description[1]:cham_description[2]],
                readme[readme_description[2]:length(readme)])
  }
  if ("installation" %in% parts) {
    readme_install <- c(grep("<!-- install: start -->", readme),
                        grep("<!-- install: end -->", readme))
    if (length(readme_install ) != 2) {stop("Readme lacks tags: <!-- install : start --> and/or <!-- install : end -->")}
    
    cham_install <- c(grep("<!-- install: start -->", cham_desc) + 1,
                      grep("<!-- install: end -->", cham_desc) - 1)
    
    readme <- c(readme[1:readme_install[1]],
                cham_desc[cham_install[1]:cham_install[2]],
                readme[readme_install[2]:length(readme)])
  }
  
  readr::write_lines(enc2utf8(readme), readme_path)
  if (isTRUE(edit)) {
    usethis::edit_file(readme_path)
    message(crayon::green("You can now edit "), readme_path)
  }
}

