# Writing `Time.LocalDate` tests

What to know before adding a case here. Ports of test262 cases go under
`test/test262/built-ins/Temporal/PlainDate` instead; see `test/test262/AGENTS.md`.

## What belongs here

A case belongs here when `Temporal.PlainDate` has nothing to port it from:

- **Constructors and ends of the range** `Temporal` lacks or names by parsing a string:
  `tryOfEpochDay`, `tryOfYearDay`, and that `min`/`max` are -9999-01-01 and 9999-12-31.
- **`Int64` amounts at their ends.** `Temporal.Duration` refuses oversized parts before
  adding, so the ends of `Int64` never reach `add`. Here they do: negating
  `Int64.minValue()` for `minus`, or multiplying it into days or months, overflows an
  `Int64`, so every amount is taken to both ends.
- **Day counts outside the range.** The constructor `LocalDate(Int64)` is public. Day and
  week arithmetic adds such a count exactly (a sum back in range is a date; one that would
  wrap is not); month/year arithmetic and `with*` report it as out of range.
- **Year 0 and negative years.** The ported cases all use years from 1 onwards.

## Building dates

Use the test262 harness (`TemporalHelpers`): `plainDate` to build a date and
`assertPlainDate` / `assertSomePlainDate` / `assertNoPlainDate` to check one. `plainDate`
works the day count out without `Time.LocalDate`, so a case does not depend on `tryOf`. It
reaches back to year -9999 only; build anything earlier from `min()`.

## Checking a guard

A case that claims a guard is needed must turn red when the guard is loosened. Check it by
mutation: break the guard, run `flix test`, see the intended case fail, then restore it.
