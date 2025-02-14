test_that("commonmeta_doi() works", {
  skip_on_ci()
  expect_type(commonmeta_doi(), "character")
  expect_equal(nchar(commonmeta_doi()), 36)
})
