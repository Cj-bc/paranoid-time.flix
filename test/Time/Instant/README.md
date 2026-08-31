# `Time.Instant` tests

Modelled on [test262's `test/built-ins/Temporal/Instant`][test262]: one file per
public function, each case named after the property it pins down.

Every test carries a doc comment naming the test262 case it was adapted from, or
saying plainly that it has no counterpart there. References are against test262
[`7710052`][rev] (2026-08-30) and are written relative to
`test/built-ins/Temporal/`.

| File | Covers |
| --- | --- |
| `Harness.flix` | Shared helpers (no tests). `Instant` does not derive `ToString`, so these unwrap it into the milliseconds it carries, which both makes it comparable with `Assert.assertEq` and makes a failure print the numbers that differ. |
| `Now.flix` | `now` |
| `TryAdd.flix` | `tryAdd` |
| `SaturatingAdd.flix` | `saturatingAdd` |
| `TrySub.flix` | `trySub` |
| `SaturatingSub.flix` | `saturatingSub` |
| `Between.flix` | `between` |
| `Compare.flix` | The derived `Eq`, `Order` and `Hash` instances |

Run them with `flix test`.

## What came from where

`Instant` here is a millisecond `Int64` and `Duration` is a nanosecond `Int64`,
where a `Temporal.Instant` counts nanoseconds and a `Temporal.Duration` is a
property bag. Where Temporal throws a `RangeError`, this library returns `None`
or clamps. So no case transfers verbatim; each one below carries over the
*property* being checked and the inputs that exercise it.

| This file | test262 cases it draws on |
| --- | --- |
| `Now.flix` | `Now/instant/return-value-value.js`, `Now/instant/return-value-distinct.js` |
| `TryAdd.flix` | `Instant/prototype/add/`: `basic.js`, `blank-duration.js`, `cross-epoch.js`, `minimum-maximum-instant.js`, `result-out-of-range.js`, `add-large-subseconds.js` |
| `SaturatingAdd.flix` | the same `add/` cases, with clamping in place of the `RangeError` |
| `TrySub.flix` | `Instant/prototype/subtract/`: `basic.js`, `blank-duration.js`, `minimum-maximum-instant.js`, `result-out-of-range.js`, `subtract-large-subseconds.js`; plus `add/cross-epoch.js` and `until/add-subtract.js` |
| `SaturatingSub.flix` | the same `subtract/` cases, with clamping in place of the `RangeError` |
| `Between.flix` | `Instant/prototype/until/`: `add-subtract.js`, `blank-result.js`, `subseconds.js`, `float64-representable-integer.js`; plus `since/add-subtract.js` and `Instant/limits.js` |
| `Compare.flix` | `Instant/compare/exhaustive.js`, `compare/cross-epoch.js`, `Instant/prototype/equals/basic.js`, `equals/cross-epoch.js` |

Some cases have no test262 counterpart at all, and say so in place:

- **Sub-millisecond truncation** (`tryAdd06`, `tryAdd07`, and the `*05`
  truncation cases). A `Temporal.Instant` counts nanoseconds, so a
  sub-millisecond duration is exact there; truncation only arises from pairing a
  millisecond `Instant` with a nanosecond `Duration`.
- **The saturating variants agreeing with the `try*` ones**
  (`saturatingAdd09`, `saturatingSub10`). Temporal has only the throwing form.
- **`trySub` not being `tryAdd`** (`trySub15`, `saturatingSub11`). Temporal has
  never needed to state this; it is here because this library currently gets it
  wrong.
- **`between` never being negative** (`between10`). `until` and `since` are
  signed, so the invariant does not exist in Temporal.
- **Sorting and hashing** (`compare05`, `compare06`). `Array.prototype.sort` and
  Flix's derived `Hash` have no test262 equivalent.
- **Pinning the clock** (`now02`, `now03`, `now04`). test262 cannot stub the
  clock; handling the `Clock` effect in the test can.

## Failing tests

These tests describe what each function is meant to do, not what it currently
does, so some of them fail against `src/Time/Instant.flix` today. Three defects
are pinned down:

1. **`trySub` and `saturatingSub` add instead of subtracting.**
   `internalTrySub` destructures the duration and passes it straight back to
   `internalTryAdd` without negating it, so `trySub(t, d)` returns `t + d`. The
   overflow checks follow the wrong direction as a consequence: subtracting from
   `Int64.minValue()` is reported as representable, and subtracting a negative
   duration from `Int64.maxValue()` silently succeeds instead of clamping.

2. **The `Int64.minValue()` branch of `internalTrySub` mixes units.**
   `Duration` counts nanoseconds and `Instant` counts milliseconds. The branch
   compensates for the un-negatable `Int64.minValue()` by adding
   `Duration.milliseconds(1)`, a million times the nanosecond it means to add,
   which lands one millisecond past the right answer. Truncating the duration to
   milliseconds *before* negating it avoids the special case entirely: no
   millisecond count reachable from an `Int64` of nanoseconds is `Int64.minValue()`.

3. **`between` overflows.** `t1 - t2` is computed in `Int64` and wraps for wide
   gaps, so `between(Instant(Int64.minValue()), Instant(Int64.maxValue()))`
   reports a 1 ms gap. `Int64.abs` compounds it: it returns `-1i64` for
   `Int64.minValue()`, so `between(Instant(0), Instant(Int64.minValue()))`
   reports a *negative* duration, which `between` should never produce. Both
   gaps are far too wide for the `Int32` of milliseconds the result is built
   from, so both should be `None`.

[test262]: https://github.com/tc39/test262/tree/main/test/built-ins/Temporal/Instant
[rev]: https://github.com/tc39/test262/commit/771005236e88a909635104e03ba12559688c0172
