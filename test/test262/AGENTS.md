# Porting test262 cases

What to know before adding or changing a port under `test/test262/`. Licence and source
revisions are in `README.md`.

## Where a case goes

Only cases that carry a test262 case over live here. Cases about behaviour test262 has
nothing to say about go in `test/TestTime/Instant/` or `test/TestTime/LocalDate/`.

The one exception is the `saturating` half of an out-of-range case: `Temporal` has only the
throwing form, but the case still tests what test262 tests — the boundary — so it stays
here beside its `try` half, marked as having no counterpart.

## Layout and module names

The directory layout mirrors test262's: `test/built-ins/Temporal/X/....js` becomes
`built-ins/Temporal/X/....flix`, and nothing else about the path changes.

- A `pub mod A.B.C` has to live in a file whose path ends `A/B/C.flix`. `TemporalHelpers`
  is `pub` — the test files `use` it — so it is a top-level module in
  `harness/TemporalHelpers.flix`, not test262's lower-case name.
- A non-`pub` `mod` is free of that rule but cannot be `use`d from another file. Each test
  file is one, named after its own path (`Test262.BuiltIns.Temporal.PlainDate.Prototype.Add.Basic`),
  which is what lets the files keep test262's hyphenated names.

## Each ported file

Starts with the copyright line of the test262 file it came from, then:

```flix
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.LocalDate; the module doc comment says what changed.
```

The module doc comment names the source file and its `esid`, and says what was restated
and why. Each case's doc comment quotes the test262 assertion it stands for.

## Translating Instant cases

- **The instant.** `Temporal.Instant` is one signed nanosecond count; `Time.Instant` is a
  second count plus a nanosecond-of-second in `[0, 999999999]`. Restate every expectation
  as that pair, with the arithmetic in the comment. Before the epoch `nano` stays
  non-negative, so the second count is one below the truncating division.
- **The range.** `Temporal.Instant` ends at ±8.64e21 ns; `Time.Instant` ends at two
  calendar instants a day inside the four-digit year range. Cases that step one unit past
  an end come over; cases that walk from one end to the other in one operation do not,
  since no `Duration` spans the range.
- **The duration.** `Time.Duration` is one `Int64` nanosecond count, a little over 292
  years. A ten-argument `Temporal.Duration` becomes a sum of the per-unit constructors.
  Arguments that do not fit are dropped, not reinterpreted: "the argument does not fit" is
  not the claim test262 makes.
- **Out of range.** A `RangeError` becomes two cases: `try*` answers `None`, and
  `saturating*` answers the end it ran into.
- `since` and `until` both map to `between`, which answers the absolute gap as an
  `Option`.

## Translating PlainDate cases

- **The date.** Build dates with the harness's `plainDate(y, m, d)`, which stands in for
  both `new Temporal.PlainDate` and `Temporal.PlainDate.from("yyyy-mm-dd")`; check them with
  `assertPlainDate` and its `Option` variants. `plainDate` works the day count out through
  ordinal dates rather than `Time.LocalDate`, so a slip in the day arithmetic cannot hide
  behind the same slip in the accessors. Use `tryOf` only where the constructor is what the
  case is about. `plainDate` reaches back to year -9999 only.
- **The range.** `Temporal.PlainDate` runs from -271821-04-19 to 275760-09-13; `LocalDate`
  from -9999-01-01 to 9999-12-31. Restate cases about the ends against those dates.
- **The duration.** A single-unit duration becomes that unit's `tryPlus*`/`tryMinus*`. A
  duration that mixes units goes through `tryAddDuration`/`trySubtractDuration`, which apply
  the years and months together and then the weeks and days — the order `Temporal` and
  `java.time`'s `Period` use. Adding years and months separately is not the same.
- **Out of range.** As for `Instant`; check the `saturating*` half beside the `try*` one
  where the boundary is what the case is about.
- **Overflow.** `java.time` has no `overflow` option: `plusMonths`, `plusYears`, `withYear`
  and `withMonth` always constrain. Port the constrain half; the throwing half of
  `{ overflow: "reject" }` has no counterpart. `withMonth` and `withDayOfMonth` reject a
  month above 12 or a day past the month's end where `with` would constrain them.
- **The string form.** Years are written the `java.time` way, at least four digits with a
  leading `-` (`-0001`), not `Temporal`'s six (`-000001`). Restate expected strings.

## What is not ported, and why

Do not port these; there is nothing to test them against.

Both types:

- **Parsing and property bags.** `from/` (apart from PlainDate's `limits.js` and
  `negative-month-or-day.js`), `constructor.js`, every `argument-string-*.js`,
  `argument-propertybag-*.js`, `*-string*.js`, `year-zero.js`, `leap-second.js`. Neither type
  has a string form.
- **Argument coercion.** `argument-wrong-type.js`, `argument-not-object.js`,
  `argument-object-tostring.js`, `non-integer.js`, `large-bigint.js`,
  `infinity-throws-rangeerror.js`, `order-of-operations.js`. Flix checks these at compile
  time.
- **JavaScript object plumbing.** `builtin.js`, `length.js`, `name.js`, `prop-desc.js`,
  `not-a-constructor.js`, `branding.js`, `subclass*.js`,
  `get-prototype-from-constructor-throws.js`, `options-*.js`.
- **Duration shapes.** `disallowed-duration-units.js`, `argument-mixed-sign.js`,
  `argument-singular-properties.js`, `argument-invalid-property.js`,
  `balance-smaller-units*.js`. Amounts here are a single signed count, or one `Int64` per
  unit.

Instant only:

- **Rounding options.** `prototype/since/`'s `largestunit*`, `smallestunit*`,
  `roundingmode-*`, `roundingincrement*`, `valid-increments.js`, `invalid-increments.js`,
  `round-cross-unit-boundary.js`, `minutes-and-hours.js`, `largest-unit-default.js`.
  `between` takes no options.
- **Unimplemented members.** `round`, `toString`, `toJSON`, `until`, `epochMilliseconds`,
  `toZonedDateTimeISO` and the rest.
- `Temporal.Now.instant` is outside this tree; `now()` is covered by
  `test/TestMain/Instant.flix`.

PlainDate only:

- **Calendars.** `calendar-*.js`, `monthCode`, `era`, `eraYear`, `calendarId`,
  `withCalendar`, and `with/constrain-day.js` (the `gregory` copy of `constrain-days.js`).
  There is one calendar.
- **The `overflow` option.** `overflow-*.js` under `add/`, `subtract/` and `with/` except
  `subtract/overflow-constrain.js`, and the `reject` halves of the constrain cases.
- **Durations `LocalDate` cannot take.** `argument-duration-*.js`. How the `Int64` amounts
  behave at their ends is in `test/TestTime/LocalDate/`.
- **Unimplemented members.** `since`, `until`, `weekOfYear`, `yearOfWeek`, `daysInWeek`,
  `monthsInYear`, `toJSON`, `toLocaleString`, `valueOf`, `toPlainDateTime`,
  `toPlainMonthDay`, `toPlainYearMonth`, `toZonedDateTime`.
