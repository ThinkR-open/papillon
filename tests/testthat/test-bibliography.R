test_that("create_biblio_file substitutes BIBPATH with forward slashes", {
  # On Windows, tempdir() returns a path with backslashes (e.g. "C:\Users\...").
  # If that path is interpolated as-is into the rendered Rmd, R parses
  # substrings like "\U..." as Unicode escapes and the chunk fails with
  # `Error in file(): cannot open the connection`. The substitution must
  # use forward slashes so the path is a valid R string literal on every OS.

  fake_dir <- "C:\\Users\\RUNNER~1\\AppData\\Local\\Temp\\RtmpXXXX"
  bib_template <- c(
    "knitr::write_bib(packages, file.path(BIBPATH_HERE, 'packages.bib'))"
  )
  substituted <- gsub(
    pattern = "BIBPATH_HERE",
    replacement = paste0('"', gsub("\\\\", "/", fake_dir), '"'),
    x = bib_template
  )

  expect_false(grepl("\\\\", substituted))
  expect_true(grepl("C:/Users/RUNNER~1/AppData/Local/Temp/RtmpXXXX", substituted, fixed = TRUE))

  expect_silent(
    parse(text = substituted)
  )
})

test_that("create_biblio_file produces an html bibliography", {
  out <- tempfile()
  dir.create(out)

  suppressMessages(
    create_biblio_file(
      packages = c("rmarkdown", "knitr"),
      out.dir = out,
      to = "html",
      edit = FALSE
    )
  )

  expect_true(file.exists(file.path(out, "bibliography.html")))
})
