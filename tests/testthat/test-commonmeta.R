test_that("commonmeta_doi() works", {
  commonmeta_install()
  expect_type(commonmeta_doi(), "character")
  expect_true(nzchar(commonmeta_doi()))
})

test_that("commonmeta_doi() errors well", {
  withr::local_envvar("commonmetar.commonmeta.not.here" = "yay")
  expect_snapshot_error(commonmeta_doi())
})
