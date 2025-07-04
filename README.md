
# earlychallenges

The goal of earlychallenges is to reflect on past code regarding data cleaning, validation, and plotting epicurves, comparing them with new solutions provided by `{cleanepi}`, `{linelist}`, `{incidence2}`

## References

Each R file is a copy of a reprex available in a Gist entry:

- 01 fix spelling from <https://gist.github.com/avallecam/4b90693bc2e540f1ee819c01563c5886>
- 02 fix spelling from <https://gist.github.com/avallecam/bcdb8ca98b40e7276a7269b72e564d85>
- 03 fix duplicates from <https://gist.github.com/avallecam/f40d4180cb0e34417b319162a4489ea6>
- 04 fix multiple date formats from <https://gist.github.com/avallecam/b221a91054e7a3da743a4e5b27187ca9>
- 05 complete a time series from <https://gist.github.com/avallecam/894e0e2f5db3ec17cf78d2e6d9b04bbd> 
- 06 aggregate a time series from <https://gist.github.com/avallecam/b5b9738c4eede2f1008daa514aeab2ae>
- 07 plot case as rectangles from <https://gist.github.com/avallecam/15543b7bdf9ea1b7e3006162ac5dda0e>

> Do you want to write your own reprex?
> 
> - `{reprex}` is a package to create reproducible examples <https://reprex.tidyverse.org/>
> - How to post an R code questions? <https://community.appliedepi.org/t/how-to-post-an-r-code-question/623>

## Usage

1. Open the R files in consecutive order.
2. Run the content step-by-step or line-by-line to explore how a set of task are coded to solve an end goal.

## License

[MIT](https://choosealicense.com/licenses/mit/)

## Installation

Get a local copy:

1. Fork and clone the repository: <https://github.com/avallecam/epiversetracer>
2. Restore the R environment running:

```r
if(!require("renv")) install.packages("renv")
renv::restore()
```

