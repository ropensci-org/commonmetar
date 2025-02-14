test_that("commonmeta_doi() works", {
  commonmeta_install()
  expect_type(commonmeta_doi(), "character")
  expect_equal(nchar(commonmeta_doi()), 36)
})
