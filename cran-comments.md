
## CRAN submission: LikertMakeR 1.2.0

### Changes in this version

- New function `makePaired()` for generating paired-sample datasets from t-test statistics
- Updated `lcor()` algorithm that overcomes possible biased distributions in extreme values
- Updated `makeCorrLoadings()` with improved diagnostics
- Minor documentation updates 

### Test environments

- local: Windows 11, R 4.4.0 and R 4.5.0 (devel)
- rhub: Windows (R-devel), Ubuntu (R-release), macOS (R-release)
- win-builder: R-devel

### R CMD check results

All checks passed with no ERRORs, WARNINGs, or unaddressed NOTEs.

### Additional comments

- The package includes a `_pkgdown.yml` and a `docs/` folder, which are excluded from the CRAN build via `.Rbuildignore`.
- The NOTE about “future file timestamps” on Windows is spurious and can be safely ignored.

## R CMD check results

0 errors | 0 warnings | 1 note

* update with one new function and some code tweaks for efficiency


