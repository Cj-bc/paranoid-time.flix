# `Time.LocalDate` tests with no test262 counterpart

`test/test262/built-ins/Temporal/PlainDate` holds the cases carried over from
[tc39/test262][test262]. This directory holds the rest: assertions about `Time.LocalDate`
(and `Time.DayOfWeek`) that test262 has nothing to say about.

[test262]: https://github.com/tc39/test262

| File | Under test |
| --- | --- |
| `Range.flix` | `min`, `max` |
| `OfEpochDay.flix` | `tryOfEpochDay`, `saturatingOfEpochDay` |
| `TryOfYearDay.flix` | `tryOfYearDay` |
| `Fields.flix` | the field accessors away from the present, `getDayOfWeek` on known days |
| `DayArithmetic.flix` | `{try,saturating}{Plus,Minus}{Days,Weeks}` |
| `MonthArithmetic.flix` | `{try,saturating}{Plus,Minus}{Months,Years}` |
| `With.flix` | `tryWithDayOfYear`, and the `with*` functions on values outside the range |
| `Compare.flix` | `isBefore`, `isAfter`, `isEqual` |
| `ToString.flix` | `ToString[LocalDate]` at and beyond the ends |
| `DayOfWeek.flix` | `Time.DayOfWeek` |

## Why these have no counterpart

**The constructors.** `Temporal.PlainDate` is built from a year, month and day, or parsed.
`tryOfEpochDay` and `tryOfYearDay` have nothing to port from, and neither has the claim that
`min` and `max` are -9999-01-01 and 9999-12-31, since `Temporal` names its own ends by
parsing a string.

**The amounts are `Int64`s.** `Temporal.Duration` refuses parts beyond its own limits before
anything is added, so the ends of `Int64` never reach `add`. Here they do, and each of them
has to be taken exactly: negating `Int64.minValue()` for `minus`, or multiplying it into days
or months, overflows an `Int64`. `DayArithmetic.flix` and `MonthArithmetic.flix` take every
amount to both ends, and check the width of the range from both sides.

**The constructor is public.** `LocalDate(Int64)` can hold a day count outside the range.
The day and week arithmetic adds such a count exactly, so a sum that comes back into the range
is a date and one that would wrap round is not. The month and year arithmetic and the `with*`
functions count from the fields, which such a value has none of, and report it as out of
range.

**Year 0 and negative years.** Every date test262's `PlainDate` basics pick is between 1900
and 2100. `Fields.flix` checks the accessors on either side of year 0 and at the ends of the
range, including leap years numbered astronomically.

## Checked by mutation

Each guard was loosened in turn — the clamp on the month count, the exact day sum, the range
check before the month arithmetic and before `with*`, the constant for `min`, the `+` sign,
the 400-year leap rule, the week multiplier and the day-of-week offset — and each turned at
least one case red.

## Licence

These cases are not derived from test262, so they carry no test262 copyright notice and are
under this repository's own licence.

## Helpers

The date builders and the assertions come from `test/test262/harness`, shared with the
ports. `plainDate` works its day count out through ordinal dates, so a case here does not
depend on `tryOf` being right; it covers the years -9999 onwards only, so the one case that
needs a year before that builds it from `min` instead.
