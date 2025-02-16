
<!-- README.md is generated from README.Rmd. Please edit that file -->

# commonmetar

<!-- badges: start -->

[![R-CMD-check](https://github.com/maelle/commonmetar/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/maelle/commonmetar/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of commonmetar is to allow rOpenSci blog editors to generate a
random DOI strings for rOpenSci blog posts, that [Rogue
Scholar](https://rogue-scholar.org/) will then use for registration.

This package wraps the [commonmeta Go
library](https://github.com/front-matter/commonmeta).

## Setup

You can install the development version of the commonmetar R package
from [GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("ropensci-org/commonmetar")
```

Install the commonmeta Go library with

``` r
commonmetar::commonmeta_install()
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(commonmetar)
commonmeta_doi()
#> [1] "https://doi.org/10.59350/wtb4q-ag214"
```
