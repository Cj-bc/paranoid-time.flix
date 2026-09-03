# test262 ports

`Time.Instant` cases carried over from [tc39/test262][test262], kept in the directory
layout the originals have so that each file can be read next to its source.

Source revision: [`2808d41`][rev] (`test/built-ins/Temporal/Instant`).

[test262]: https://github.com/tc39/test262
[rev]: https://github.com/tc39/test262/tree/2808d4143f00993c2e65456d9a99b8f82b6743f9/test/built-ins/Temporal/Instant

## Layout

```
test/test262/
  harness/TemporalHelpers.flix        <- test262's harness/temporalHelpers.js
  built-ins/Temporal/Instant/...      <- test/built-ins/Temporal/Instant/...
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
| `fromEpochMilliseconds/basic.flix` | `fromEpochMilliseconds/basic.js` | `fromEpochMilliseconds` |
| `fromEpochMilliseconds/limits.flix` | `fromEpochMilliseconds/limits.js` | `fromEpochMilliseconds` |
| `fromEpochNanoseconds/basic.flix` | `fromEpochNanoseconds/basic.js` | `fromEpochNanoseconds` |
| `fromEpochNanoseconds/limits.flix` | `fromEpochNanoseconds/limits.js` | `fromEpochNanoseconds` |
| `prototype/add/basic.flix` | `prototype/add/basic.js` | `tryAdd`, `saturatingAdd` |
| `prototype/add/blank-duration.flix` | `prototype/add/blank-duration.js` | `tryAdd`, `saturatingAdd` |
| `prototype/add/cross-epoch.flix` | `prototype/add/cross-epoch.js` | `tryAdd`, `trySub` |
| `prototype/add/minimum-maximum-instant.flix` | `prototype/add/minimum-maximum-instant.js` | `tryAdd`, `saturatingAdd` |
| `prototype/add/result-out-of-range.flix` | `prototype/add/result-out-of-range.js` | `tryAdd`, `saturatingAdd` |
| `prototype/add/add-large-subseconds.flix` | `prototype/add/add-large-subseconds.js` | `tryAdd` |
| `prototype/add/argument-duration-max.flix` | `prototype/add/argument-duration-max.js` | `tryAdd` |
| `prototype/equals/basic.flix` | `prototype/equals/basic.js` | `Eq[Instant]` |
| `prototype/equals/cross-epoch.flix` | `prototype/equals/cross-epoch.js` | `Eq[Instant]` |
| `prototype/since/add-subtract.flix` | `prototype/since/add-subtract.js` | `between`, `tryAdd`, `trySub` |
| `prototype/since/blank-result.flix` | `prototype/since/blank-result.js` | `between` |
| `prototype/since/subseconds.flix` | `prototype/since/subseconds.js` | `between` |
| `prototype/since/float64-representable-integer.flix` | `prototype/since/float64-representable-integer.js` | `between` |
| `prototype/subtract/basic.flix` | `prototype/subtract/basic.js` | `trySub`, `saturatingSub` |
| `prototype/subtract/blank-duration.flix` | `prototype/subtract/blank-duration.js` | `trySub`, `saturatingSub` |
| `prototype/subtract/minimum-maximum-instant.flix` | `prototype/subtract/minimum-maximum-instant.js` | `trySub`, `saturatingSub` |
| `prototype/subtract/result-out-of-range.flix` | `prototype/subtract/result-out-of-range.js` | `trySub`, `saturatingSub` |
| `prototype/subtract/subtract-large-subseconds.flix` | `prototype/subtract/subtract-large-subseconds.js` | `trySub` |
| `prototype/subtract/argument-duration-max.flix` | `prototype/subtract/argument-duration-max.js` | `trySub`, `tryAdd` |

## How the cases were translated

Nothing carried over unchanged. Four differences run through every file, and each case's
doc comment says which property it kept and how the expected value had to be restated.

**The instant.** `Temporal.Instant` is one signed nanosecond count; `Time.Instant` is a
second count plus a nanosecond-of-second in `[0, 999999999]`. Every expectation is
restated as that pair, with the arithmetic spelled out in the comment. Pre-epoch instants
are where the two forms part company: `nano` stays non-negative, so the second count sits
one below the truncating division.

**The range.** `Temporal.Instant` ends at ±8.64e21 ns. Here it ends at the two ends of the
`Int64` second line, with `nano` at 0 at the bottom and 999999999 at the top. The range is
far wider, so cases that walk from one end to the other in a single operation have no
counterpart; cases that step one nanosecond past an end do.

**The duration.** `Temporal.Duration` is a property bag with calendar units;
`Time.Duration` is one `Int64` nanosecond count. A ten-argument `Temporal.Duration`
becomes a sum of the per-unit constructors. The count tops out a little over 292 years, so
some of test262's arguments cannot be built at all — those cases are dropped rather than
reinterpreted, since "the argument does not fit" is not the claim test262 is making.

**Out of range.** `Temporal` throws a `RangeError`. Here the operation is split in two, so
one test262 case usually becomes two: `try*` answers `None`, and `saturating*` answers the
end it ran into. The saturating half has no counterpart in test262 at all — `Temporal` has
only the throwing form — and is marked as such where it appears.

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
  `epochMilliseconds`, `epochNanoseconds`, `toZonedDateTimeISO` and the rest.

`Temporal.Now.instant` lives outside this tree, under
`test/built-ins/Temporal/Now/instant/`; `now()` is covered by `test/TestMain/Instant.flix`.
