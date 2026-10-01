# test262 ports

`Time.Instant` and `Time.LocalDate` cases carried over from [tc39/test262][test262], kept in
the directory layout the originals have so that each file can be read next to its source.

Source revisions:

- [`2808d41`][rev] (`test/built-ins/Temporal/Instant`).
- [`7ab7faf`][rev-plaindate] (`test/built-ins/Temporal/PlainDate`). `Temporal.PlainDate` is the
  counterpart of `LocalDate`; its cases are covered in [PlainDate](#plaindate) below. The rest
  of this README, above that section, is about `Instant`.

[test262]: https://github.com/tc39/test262
[rev]: https://github.com/tc39/test262/tree/2808d4143f00993c2e65456d9a99b8f82b6743f9/test/built-ins/Temporal/Instant
[rev-plaindate]: https://github.com/tc39/test262/tree/7ab7fafa0003f73fc85c1b95d88094d33f7eb8bd/test/built-ins/Temporal/PlainDate

## Licence

The cases here are derived from test262, which is published by Ecma International under
the BSD 3-clause licence. A verbatim copy is in `test/test262/LICENSE`, and every ported
file keeps the copyright notice of the test262 file it came from, as that licence
requires:

```flix
// Copyright (C) 2021 Igalia, S.L. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.Instant; the module doc comment says what changed.
```

The notices name Igalia, Bloomberg LP, André Bargull and the V8 project authors, each on
the files they wrote. `harness/TemporalHelpers.flix` is *not* derived from test262's
`harness/temporalHelpers.js` — it only plays the same role — so it carries no such notice
and is under this repository's own licence, as is the rest of the project.

## Layout

```
test/test262/
  harness/TemporalHelpers.flix        <- test262's harness/temporalHelpers.js
  built-ins/Temporal/Instant/...      <- test/built-ins/Temporal/Instant/...
  built-ins/Temporal/PlainDate/...    <- test/built-ins/Temporal/PlainDate/...
```

`.js` becomes `.flix`; nothing else about a path changes.

Only cases that carry a test262 case over live here. Cases about behaviour test262 has
nothing to say about are in `test/TestTime/Instant/`, one file per function — see the
README there.

Two Flix rules shape the module declarations:

- A `pub mod A.B.C` has to live in a file whose path ends `A/B/C.flix`. `TemporalHelpers`
  is `pub` — the test files `use` it — so it is a top-level module and its file has to be
  named after it, which is why it is `TemporalHelpers.flix` rather than the lower-case name
  test262 gives it.
- A non-`pub` `mod` is free of that rule but cannot be `use`d from another file. Each test
  file is one, named `Test262.BuiltIns.Temporal.Instant....` after its own path, which is
  what lets the files keep test262's hyphenated names.

## What each file covers

| This file | test262 case | Under test |
| --- | --- | --- |
| `built-ins/Temporal/Instant/basic.flix` | `basic.js` | the two-field representation |
| `built-ins/Temporal/Instant/limits.flix` | `limits.js` | the ends of the range |
| `compare/exhaustive.flix` | `compare/exhaustive.js` | `Order[Instant]` |
| `compare/cross-epoch.flix` | `compare/cross-epoch.js` | `Order[Instant]` |
| `fromEpochMilliseconds/basic.flix` | `fromEpochMilliseconds/basic.js` | `saturatingOfEpochMilli` |
| `fromEpochMilliseconds/limits.flix` | `fromEpochMilliseconds/limits.js` | `saturatingOfEpochMilli`, `tryOfEpochMilli` |
| `fromEpochNanoseconds/basic.flix` | `fromEpochNanoseconds/basic.js` | `ofEpochNanos` |
| `fromEpochNanoseconds/limits.flix` | `fromEpochNanoseconds/limits.js` | `ofEpochNanos` |
| `prototype/add/basic.flix` | `prototype/add/basic.js` | `tryPlus`, `saturatingPlus` |
| `prototype/add/blank-duration.flix` | `prototype/add/blank-duration.js` | `tryPlus`, `saturatingPlus` |
| `prototype/add/cross-epoch.flix` | `prototype/add/cross-epoch.js` | `tryPlus`, `tryMinus` |
| `prototype/add/minimum-maximum-instant.flix` | `prototype/add/minimum-maximum-instant.js` | `tryPlus`, `saturatingPlus` |
| `prototype/add/result-out-of-range.flix` | `prototype/add/result-out-of-range.js` | `tryPlus`, `saturatingPlus` |
| `prototype/add/add-large-subseconds.flix` | `prototype/add/add-large-subseconds.js` | `tryPlus` |
| `prototype/add/argument-duration-max.flix` | `prototype/add/argument-duration-max.js` | `tryPlus` |
| `prototype/epochNanoseconds/basic.flix` | `prototype/epochNanoseconds/basic.js` | `toEpochNanos` |
| `prototype/equals/basic.flix` | `prototype/equals/basic.js` | `Eq[Instant]` |
| `prototype/equals/cross-epoch.flix` | `prototype/equals/cross-epoch.js` | `Eq[Instant]` |
| `prototype/since/add-subtract.flix` | `prototype/since/add-subtract.js` | `between`, `tryPlus`, `tryMinus` |
| `prototype/since/blank-result.flix` | `prototype/since/blank-result.js` | `between` |
| `prototype/since/subseconds.flix` | `prototype/since/subseconds.js` | `between` |
| `prototype/since/float64-representable-integer.flix` | `prototype/since/float64-representable-integer.js` | `between` |
| `prototype/subtract/basic.flix` | `prototype/subtract/basic.js` | `tryMinus`, `saturatingMinus` |
| `prototype/subtract/blank-duration.flix` | `prototype/subtract/blank-duration.js` | `tryMinus`, `saturatingMinus` |
| `prototype/subtract/minimum-maximum-instant.flix` | `prototype/subtract/minimum-maximum-instant.js` | `tryMinus`, `saturatingMinus` |
| `prototype/subtract/result-out-of-range.flix` | `prototype/subtract/result-out-of-range.js` | `tryMinus`, `saturatingMinus` |
| `prototype/subtract/subtract-large-subseconds.flix` | `prototype/subtract/subtract-large-subseconds.js` | `tryMinus` |
| `prototype/subtract/argument-duration-max.flix` | `prototype/subtract/argument-duration-max.js` | `tryMinus`, `tryPlus` |

## How the cases were translated

Nothing carried over unchanged. Four differences run through every file, and each case's
doc comment says which property it kept and how the expected value had to be restated.

**The instant.** `Temporal.Instant` is one signed nanosecond count; `Time.Instant` is a
second count plus a nanosecond-of-second in `[0, 999999999]`. Every expectation is
restated as that pair, with the arithmetic spelled out in the comment. Pre-epoch instants
are where the two forms part company: `nano` stays non-negative, so the second count sits
one below the truncating division.

**The range.** `Temporal.Instant` ends at ±8.64e21 ns, a round nanosecond count about
273790 years either side of the epoch. Here it ends at two calendar instants,
-9999-01-02T00:00:00Z and 9999-12-30T23:59:59.999999999Z, with `nano` at 0 at the bottom
and 999999999 at the top — the four-digit year range pulled in by one day at each end, so
that every instant in it still names a four-digit year once a UTC offset is applied. That
is about 27 times narrower than `Temporal`'s, but still about 2000 times more than a
`Duration` spans, so cases that walk from one end of the range to the other in a single
operation have no counterpart; cases that step one unit past an end do. That the two ends
really are those dates is checked in `test/TestTime/Instant/Range.flix`, since `Temporal`
names them by parsing a string and `Instant` has no string form.

**The duration.** `Temporal.Duration` is a property bag with calendar units;
`Time.Duration` is one `Int64` nanosecond count. A ten-argument `Temporal.Duration`
becomes a sum of the per-unit constructors. The count tops out a little over 292 years, so
some of test262's arguments cannot be built at all — those cases are dropped rather than
reinterpreted, since "the argument does not fit" is not the claim test262 is making.

**Out of range.** `Temporal` throws a `RangeError`. Here the operation is split in two, so
one test262 case usually becomes two: `try*` answers `None`, and `saturating*` answers the
end it ran into. The saturating half has no counterpart in test262 at all — `Temporal` has
only the throwing form — and is marked as such where it appears.

`toEpochNanos` answers a `BigInt`, as `epochNanoseconds` does, so it is the one operation
with nothing extra to say about being out of range. `basic.js` is all that comes over, and
how the two stored fields are put back together — which `Temporal` has no counterpart for,
since it holds the count directly — is pinned in `test/TestTime/Instant/ToEpochNanos.flix`.

`since` and `until` are both covered by `between`, which differs from both: it answers the
*absolute* gap, so the argument order does not matter, and it answers an `Option`, since a
gap wider than a `Duration` has no answer.

The one exception to "nothing carried over unchanged" being enough to keep a case here is
the `saturating` half of an out-of-range case: `Temporal` has only the throwing form, but
the case is still testing what test262 tests — the boundary — so it stays with its `try`
half rather than moving out. Everything else with no test262 case behind it is in
`test/TestTime/Instant/`.

## What is not ported

Whole groups of test262 files have nothing to test against here:

- **Parsing.** `from/`, `constructor.js`, and every `argument-string-*.js`,
  `instant-string*.js`, `year-zero.js`, `leap-second.js`. `Instant` has no string form, so
  the timestamps test262 names are spelled out as second/nanosecond pairs instead.
- **Argument coercion.** `argument-wrong-type.js`, `argument-not-object.js`,
  `argument-object-tostring.js`, `non-integer.js`, `large-bigint.js`,
  `infinity-throws-rangeerror.js`, `order-of-operations.js`. Flix checks these at compile
  time.
- **JavaScript object plumbing.** `builtin.js`, `length.js`, `name.js`, `prop-desc.js`,
  `not-a-constructor.js`, `branding.js`, `subclass*.js`,
  `get-prototype-from-constructor-throws.js`.
- **Calendar units in a duration.** `disallowed-duration-units.js`,
  `argument-mixed-sign.js`, `argument-singular-properties.js`,
  `argument-propertybag-optional-properties.js`, `argument-invalid-property.js`. A
  `Time.Duration` is a single signed count with no fields to disallow or to mix signs
  between.
- **Rounding options.** All of `prototype/since/`'s `largestunit*`, `smallestunit*`,
  `roundingmode-*`, `roundingincrement*`, `options-*`, `valid-increments.js`,
  `invalid-increments.js`, `round-cross-unit-boundary.js`, `minutes-and-hours.js`,
  `largest-unit-default.js`. `between` takes no options.
- **Unimplemented members.** `prototype/`'s `round`, `toString`, `toJSON`, `until`,
  `epochMilliseconds`, `toZonedDateTimeISO` and the rest. `epochNanoseconds` *is*
  implemented, as `toEpochNanos`, so its `basic.js` is ported; the `branding.js` and
  `prop-desc.js` beside it are object plumbing and are not.

`Temporal.Now.instant` lives outside this tree, under
`test/built-ins/Temporal/Now/instant/`; `now()` is covered by `test/TestMain/Instant.flix`.

## PlainDate

`Temporal.PlainDate` cases, ported for `Time.LocalDate`. Cases about `LocalDate` behaviour
test262 has nothing to say about are in `test/TestTime/LocalDate/`.

### What each file covers

Paths are under `built-ins/Temporal/PlainDate/`.

| This file | Under test |
| --- | --- |
| `basic.flix` | `tryOf` |
| `limits.flix` | `tryOf` at the ends of the range and of each month |
| `argument-invalid.flix` | `tryOf` |
| `from/limits.flix` | `tryOf` at the ends of the range |
| `from/negative-month-or-day.flix` | `tryOf` |
| `compare/basic.flix` | `Order[LocalDate]` |
| `prototype/equals/basic.flix` | `Eq[LocalDate]`, `isEqual` |
| `prototype/year/basic.flix` | `getYear` |
| `prototype/month/basic.flix` | `getMonthValue` |
| `prototype/day/basic.flix` | `getDayOfMonth` |
| `prototype/dayOfWeek/basic.flix` | `getDayOfWeek` |
| `prototype/dayOfYear/basic.flix` | `getDayOfYear` |
| `prototype/daysInMonth/basic.flix` | `lengthOfMonth` |
| `prototype/daysInYear/basic.flix` | `lengthOfYear` |
| `prototype/inLeapYear/basic.flix` | `isLeapYear` |
| `prototype/toString/basic.flix` | `ToString[LocalDate]` |
| `prototype/toString/year-format.flix` | `ToString[LocalDate]` |
| `prototype/add/basic.flix` | `tryPlus{Days,Months,Years}`, and mixed units through `tryAddDuration` |
| `prototype/add/basic-arithmetic.flix` | `tryPlus{Days,Weeks,Months,Years}`, `tryAddDuration` |
| `prototype/add/blank-duration.flix` | `tryPlus{Days,Weeks,Months,Years}` |
| `prototype/add/constrain-days.flix` | `tryPlusMonths` |
| `prototype/add/leap-year-arithmetic.flix` | `tryPlus{Days,Weeks,Months,Years}`, `tryAddDuration` |
| `prototype/add/limits.flix` | `tryPlusDays`, `saturatingPlusDays` |
| `prototype/add/month-boundary.flix` | `tryPlusMonths`, `tryPlusDays` |
| `prototype/add/overflow-adding-months-to-max-year.flix` | `tryAddDuration`, `saturatingPlusMonths` |
| `prototype/subtract/basic.flix` | `tryMinus{Days,Months,Years}`, and mixed units through `trySubtractDuration` |
| `prototype/subtract/basic-arithmetic.flix` | `tryMinus{Days,Weeks,Months,Years}`, `trySubtractDuration` |
| `prototype/subtract/blank-duration.flix` | `tryMinus{Days,Weeks,Months,Years}` |
| `prototype/subtract/limits.flix` | `tryMinusDays`, `saturatingMinusDays` |
| `prototype/subtract/month-boundary.flix` | `tryMinusMonths`, `tryMinusDays` |
| `prototype/subtract/overflow-constrain.flix` | `tryMinusMonths` |
| `prototype/subtract/overflow-subtracting-months-from-min-year.flix` | `trySubtractDuration`, `saturatingMinusMonths` |
| `prototype/with/basic-year-month-day.flix` | `tryWithYear`, `tryWithMonth`, `tryWithDayOfMonth` |
| `prototype/with/constrain-days.flix` | `tryWithMonth` |
| `prototype/with/leap-year.flix` | `tryWithYear` |
| `prototype/with/overflow.flix` | `tryWithYear`, `tryWithMonth`, `tryWithDayOfMonth` |

Each file has the same name as the `.js` it came from.

### How the cases were translated

**The date.** `plainDate(y, m, d)` in the harness stands in for both
`new Temporal.PlainDate(y, m, d)` and `Temporal.PlainDate.from("yyyy-mm-dd")`. It works the
day count out through ordinal dates rather than through `Time.LocalDate`, and
`assertPlainDate` checks that count alongside the fields the accessors read back, so a
slip in the day arithmetic cannot hide behind the same slip in the accessors. The
constructor itself, where it is what a case is about, becomes `tryOf`.

**The range.** `Temporal.PlainDate` runs from -271821-04-19 to 275760-09-13. `LocalDate`
runs from -9999-01-01 to 9999-12-31, the four-digit year range. Cases about the ends are
restated against those two dates; `Instant` stops a day short at each end so that a UTC
offset can be applied, but a `LocalDate` has no offset.

**The duration.** `add` and `subtract` take a `Temporal.Duration`. `java.time`, and so
`LocalDate`, has one function per unit instead: `tryPlusDays`, `tryPlusWeeks`,
`tryPlusMonths`, `tryPlusYears` and their `minus` twins. A single-unit duration becomes
a call to that unit's function. A duration that mixes units goes through the harness's
`tryAddDuration` or `trySubtractDuration`, which apply the years and months together and
then the weeks and days — the order `Temporal` uses, and `java.time`'s `Period` too.

**Out of range.** `Temporal` throws a `RangeError`; `try*` answers `None`. Where the
boundary is what a case is about, the `saturating*` half is checked beside it, as for
`Instant`.

**Overflow.** `add`, `subtract` and `with` constrain a day to the end of a short month by
default, and throw with `{ overflow: "reject" }`. `java.time` has no such option:
`plusMonths`, `plusYears`, `withYear` and `withMonth` always constrain. So the constrain
half comes over and the throwing half of `reject` does not. `withMonth` and
`withDayOfMonth` reject a month above 12 or a day past the end of the month where `with`
would constrain them, and `with/overflow.flix` pins that.

**The string form.** `LocalDate` formats a year the way `java.time` does: at least four
digits and a leading `-` when negative, so -1 is `-0001`. `Temporal` writes a year
outside 0 to 9999 with six digits, `-000001`. `toString/year-format.flix` restates the
negative years in range accordingly.

### What is not ported

- **Parsing, property bags and calendars.** `from/` apart from `limits.js` and
  `negative-month-or-day.js`, every `argument-string-*.js`, `argument-propertybag-*.js`,
  `calendar-*.js`, `monthCode`, `era`, `eraYear`, `calendarId`, `withCalendar`,
  `year-zero.js`, `leap-second.js`. `LocalDate` has no string form and one calendar.
- **Argument coercion and JavaScript object plumbing**, as for `Instant`:
  `argument-wrong-type.js`, `infinity-throws-rangeerror.js`, `builtin.js`, `length.js`,
  `name.js`, `prop-desc.js`, `branding.js`, `subclass*.js`, `order-of-operations.js`,
  `options-*.js` and the rest.
- **The `overflow` option.** `add/`, `subtract/` and `with/`'s `overflow-*.js` except
  `subtract/overflow-constrain.js`, and the `reject` halves of the constrain cases.
  `with/constrain-day.js` repeats `constrain-days.js` for the `gregory` calendar.
- **Durations `LocalDate` cannot take.** `argument-duration-*.js`,
  `balance-smaller-units*.js`, `argument-mixed-sign.js`, `argument-singular-properties.js`:
  the amounts are `Int64`s per unit, with no time units to balance and no signs to mix.
  How they behave at the ends of `Int64` is in `test/TestTime/LocalDate/`.
- **Unimplemented members.** `since`, `until`, `weekOfYear`, `yearOfWeek`, `daysInWeek`,
  `monthsInYear`, `toJSON`, `toLocaleString`, `valueOf`, `toPlainDateTime`,
  `toPlainMonthDay`, `toPlainYearMonth` and `toZonedDateTime`.
