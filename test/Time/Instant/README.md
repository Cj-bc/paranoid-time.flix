# `Time.Instant` tests

Modelled on [test262's `test/built-ins/Temporal/Instant`][test262]: one file per
public function, each case named `subject_precondition_expectation`.

Every test carries a doc comment naming the test262 case it was adapted from, or
saying plainly that it has no counterpart there. References are against test262
[`7710052`][rev] (2026-08-30) and are written relative to
`test/built-ins/Temporal/`.

| File | Covers |
| --- | --- |
| `Harness.flix` | Shared helpers (no tests). `Instant` holds a record, which Flix cannot derive `ToString` for, so these take an instant apart into its two fields — making it comparable with `Assert.assertEq` and making a failure print the numbers that differ. |
| `Now.flix` | `now` |
| `TryAdd.flix` | `tryAdd` |
| `SaturatingAdd.flix` | `saturatingAdd` |
| `TrySub.flix` | `trySub` |
| `SaturatingSub.flix` | `saturatingSub` |
| `Between.flix` | `between` |
| `Compare.flix` | The hand-written `Eq`, `Order` and `Hash` instances |

Run them with `flix test`.

This suite sits alongside `test/TestMain/Instant.flix`, which covers the same
functions more briefly. The two overlap; what this one adds is the per-function
layout, the test262 provenance on each case, and a wider sweep of the boundaries.

## What the cases concentrate on

An `Instant` is a whole-second `Int64` plus a `nano` pinned to
[0, 999_999_999], so almost every operation has to carry or borrow between the
two fields and keep `nano` in range. That shapes the suite:

- **Carry and borrow.** A sub-second duration that crosses a second boundary,
  in both directions, and either side of the epoch — where `nano` must stay
  non-negative even though the instant is negative.
- **The two boundaries.** Landing exactly on `minInstant()` or `maxInstant()`
  succeeds; the step past it does not. A duration under a second can overflow
  through the carry alone, which is a separate case from a duration that
  overflows on its own.
- **`Int64.minValue()` nanoseconds.** It has no positive counterpart, so
  subtracting it cannot go through a whole negation. Negating the second- and
  nano-parts of its split separately has no such problem, and the result must be
  exact rather than off by one.
- **Magnitudes wider than a `Duration`.** `between` returns nanoseconds in an
  `Int64`, so gaps beyond that must be `None` rather than a wrapped-around small
  number — and never a negative duration.

## What came from where

Nothing transfers verbatim. A `Temporal.Instant` is a single signed count of
nanoseconds where this one is two fields, a `Temporal.Duration` is a property
bag, and Temporal throws a `RangeError` where this library returns `None` or
saturates. Each case carries over the *property* being checked and the inputs
that exercise it.

| This file | test262 cases it draws on |
| --- | --- |
| `Now.flix` | `Now/instant/return-value-value.js`, `return-value-distinct.js`; `Instant/fromEpochMilliseconds/basic.js`, `limits.js`; `Instant/prototype/epochMilliseconds/basic.js` |
| `TryAdd.flix` | `Instant/prototype/add/`: `basic.js`, `blank-duration.js`, `cross-epoch.js`, `minimum-maximum-instant.js`, `result-out-of-range.js`, `add-large-subseconds.js` |
| `SaturatingAdd.flix` | the same `add/` cases, with saturation in place of the `RangeError` |
| `TrySub.flix` | `Instant/prototype/subtract/`: `basic.js`, `blank-duration.js`, `minimum-maximum-instant.js`, `result-out-of-range.js`, `subtract-large-subseconds.js`; plus `add/cross-epoch.js` and `until/add-subtract.js` |
| `SaturatingSub.flix` | the same `subtract/` cases, with saturation in place of the `RangeError` |
| `Between.flix` | `Instant/prototype/until/`: `add-subtract.js`, `blank-result.js`, `subseconds.js`, `float64-representable-integer.js`; plus `since/add-subtract.js` and `Instant/limits.js` |
| `Compare.flix` | `Instant/compare/exhaustive.js`, `compare/cross-epoch.js`, `Instant/prototype/equals/basic.js`, `equals/cross-epoch.js` |

Some cases have no test262 counterpart at all, and say so in place:

- **Anything about the two-field split** — the carry and borrow between
  `secondsSinceEpoch` and `nano`, `nano` staying non-negative, a larger `nano`
  not outranking a larger second, an overflow caused by the carry alone.
  `Temporal.Instant` has one field, so none of it arises there.
- **The saturating variants agreeing with the `try*` ones.** Temporal has only
  the throwing form.
- **`trySub` not being `tryAdd`.** Temporal has never needed to state it.
- **`between` never being negative.** `until` and `since` are signed, so the
  invariant does not exist in Temporal.
- **Sorting and hashing.** `Array.prototype.sort` and Flix's `Hash` have no
  test262 equivalent.
- **Pinning the clock.** test262 cannot stub the clock; handling the `Clock`
  effect in the test can.

[test262]: https://github.com/tc39/test262/tree/main/test/built-ins/Temporal/Instant
[rev]: https://github.com/tc39/test262/commit/771005236e88a909635104e03ba12559688c0172
