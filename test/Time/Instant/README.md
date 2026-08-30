# `Time.Instant` tests

Modelled on [test262's `test/built-ins/Temporal/Instant`][test262]: one file per
public function, each case named after the property it pins down.

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
