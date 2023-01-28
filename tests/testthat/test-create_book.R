test_that("build_book function works correctly", {
  # Create a temporary directory for testing
  test_dir <- tempfile(pattern = "buildbook")
  dir.create(test_dir)
  on.exit(unlink(test_dir, recursive = TRUE))
  
  # Create some dummy vignettes in the temporary directory
  vignettes_dir <- file.path(test_dir, "vignettes")
  dir.create(vignettes_dir)
  template_contents <- getFromNamespace("render_template", "usethis")(
      template = "vignette.Rmd", 
      data = list(Package = "papillon", vignette_title = "title1", 
                  braced_vignette_title = "{title1}"), package = "usethis")
  template_contents <- gsub(" setup", "", template_contents)
  cat(template_contents, "# Title 1\n\n content1", 
      sep = "\n", file = file.path(vignettes_dir, "vignette1.Rmd"))
  template_contents <- getFromNamespace("render_template", "usethis")(
    template = "vignette.Rmd", 
    data = list(Package = "papillon", vignette_title = "title2", 
                braced_vignette_title = "{title2}"), package = "usethis")
  template_contents <- gsub(" setup", "", template_contents)
  cat(template_contents, "# Title 2\n\n content2", 
      sep = "\n", file = file.path(vignettes_dir, "vignette2.Rmd"))  

  # Create some dummy Rmd files in the temporary directory
  report_dir <- file.path(test_dir, "inst/report")
  dir.create(report_dir, recursive = TRUE)
  file.create(file.path(report_dir, "file1.Rmd"))
  file.create(file.path(report_dir, "file2.Rmd"))
  
  # Run the build_book function
  build_book(path = report_dir, path.v = vignettes_dir, 
             output_format = "bookdown::gitbook",
             clean_before = TRUE, clean_after = FALSE,
             keep_rmd = "index\\.Rmd$|zzz-references\\.Rmd$",
             clean = TRUE)
  
  # Check that the vignettes were copied to the report directory but clean_after is TRUE
  expect_true(file.exists(file.path(report_dir, "vignette1.Rmd")))
  expect_true(file.exists(file.path(report_dir, "vignette2.Rmd")))
  
  # Check that the other Rmd files in the report directory were removed
  expect_false(file.exists(file.path(report_dir, "file1.Rmd")))
  expect_false(file.exists(file.path(report_dir, "file2.Rmd")))
  
  # Check that the book was built in the correct format
  expect_true(file.exists(file.path(report_dir, "_book")))
  # browseURL(file.path(report_dir, "_book", "title-1.html"))
})
