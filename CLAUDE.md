# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common commands

```bash
# Load package and run ad-hoc code
Rscript -e "devtools::load_all(); <code>"

# Run all tests
Rscript -e "devtools::test()"

# Run tests for a specific file (R/foo.R → tests/testthat/test-foo.R)
Rscript -e "devtools::test_active_file('R/foo.R')"

# Regenerate documentation
Rscript -e "devtools::document()"

# Full R CMD check
Rscript -e "devtools::check()"

```

## Code conventions

- Use the base pipe `|>`, not `%>%`.
- Single-line anonymous functions: `\() ...`. Multi-line: `function() { ... }`.
- No comments unless the *why* is non-obvious.
- Every exported function needs roxygen2 docs; internal functions do not.
- Use the `cli` package for errors, warnings, and messages.
- Use the `rlang` package instead of base R where appropriate.
- For readiability, prefer Markdown in roxygen

### S7 object preferences

- Use the `constructor` argument of `new_class()` instead of building separate helper functions to construct objects.
- For use `validator` functions to check properties. If validation only relies on a single value, call `validator` from `new_property()`, otherwise from `new_class()`.
- Document S7 class properties in roxygen comments.

## Dates

When adding or subtracting periods from dates, always use `lubridate`'s %m+% and %m-%.

## Dependencies

Declared in `DESCRIPTION` under `Imports`: `cli`, `dplyr`, `ggplot2`, `lubridate`, `rlang`, `S7`, `tidyr`.

## NEWS.md

Every user-facing change gets a bullet in `NEWS.md`. No bullets for internal refactors or doc-only changes.
