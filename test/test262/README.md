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

Cases with no test262 counterpart are marked "No test262 counterpart" in their doc comment
together with the reason. They fall into three groups: anything about the two-field split
(carry, borrow, `nano` staying non-negative, an overflow caused by the carry alone), the
`saturating` operations, and the properties `between` has because it is unsigned.

## A case that fails on purpose

`prototype/since/float64-representable-integer.flix::since05` asserts what the documented
contract of `between` says — "the absolute amount of time between `d1` and `d2`, or `None`
when it is too large to fit in a `Duration`" — and the implementation does not meet it.

A gap of 9223372036000000001 ns fits in a `Duration`; it is 854775806 ns under
`Int64.maxValue()`. Spread as 9223372037 whole seconds minus 999999999 nanoseconds, it is
rejected: `between` turns down a second count over 9223372036 before the negative
nanosecond difference is allowed to bring the total back under the ceiling. Every gap that
is not spread across an extra second — including the largest one, `Int64.maxValue()` ns
exactly — is reported correctly, so this is the only shape that trips it.

The case is written to the contract rather than to the behaviour, so it stays red until
`between` is fixed.

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
