# `Time.Instant` tests with no test262 counterpart

`test/test262` holds the cases carried over from [tc39/test262][test262]. This directory
holds the rest: assertions about `Time.Instant` that test262 has nothing to say about, one
file per function.

[test262]: https://github.com/tc39/test262

| File | Under test |
| --- | --- |
| `Compare.flix` | `Order[Instant]` |
| `Equals.flix` | `Eq[Instant]` |
| `FromEpochMilliseconds.flix` | `fromEpochMilliseconds` |
| `FromEpochNanoseconds.flix` | `fromEpochNanoseconds` |
| `TryAdd.flix` | `tryAdd` |
| `SaturatingAdd.flix` | `saturatingAdd` |
| `TrySub.flix` | `trySub` |
| `SaturatingSub.flix` | `saturatingSub` |
| `ToEpochNanos.flix` | `toEpochNanos` |
| `Between.flix` | `between` |

## Why these have no counterpart

Three differences account for all of them.

**`Instant` is two fields.** A second count plus a nanosecond-of-second in
`[0, 999999999]`, where `Temporal.Instant` is a single signed nanosecond count. So the carry
and the borrow between the two fields, `nano` staying non-negative on both sides of the
epoch, and the splits at the two ends of `Int64` are all questions that only arise here.

**`Duration` is one `Int64` of nanoseconds.** Its range — a little over 292 years — is far
narrower than `Instant`'s, and `Temporal.Duration` has no comparable ceiling. Its two
extremes are worth their own cases, the smallest one especially: `Int64.minValue()`
nanoseconds has no positive counterpart, so it cannot be negated as a whole.

**Out-of-range is split in two.** `Temporal` throws; here `try*` answers `None` and
`saturating*` answers the nearest representable instant. The `try*` half and the clamping
half both test the boundary test262 tests, so both stay under `test/test262` with their
port. What is here instead is what `saturating*` does when nothing goes out of range — a
claim `Temporal` has no way to make.

For `between` there is a fourth: `since` and `until` are signed, so neither the invariant
that the answer is never negative nor the ceiling above which there is no answer exists
over there.

`toEpochNanos` has one more of its own, and it is that same ceiling seen from the other
side: `epochNanoseconds` is an arbitrary-precision `BigInt` and always has an answer,
where an `Int64` count spans a little over +/-9.22e18 *nanoseconds* against an `Instant`
range of +/-9.22e18 *seconds*. So all but a billionth of that range has no count, and
where exactly the two ends of it fall — including the `nano` that pays back the borrowed
second at the bottom — is a question only this form raises.

## Cases that fail on purpose

### `ToEpochNanos.flix`: the range guard

`toEpochNanos` answers `Option[Int64]`, so `None` is its way of saying an instant is too
far from the epoch to count. Three cases hold it to that and the implementation does not
meet any of them:

- `toEpochNanos03` — `instant(9223372036, 854775808)`, one nanosecond past the largest
  count, answers `Some(-9223372036854775808)`. The guard it is checked against,
  `Int64.maxValue() - secondsSinceEpoch < nanosPerSecond()`, compares a count of *seconds*
  against a count of *nanoseconds per second*; it only bites above about 9.22e18 seconds,
  which is nine orders of magnitude too high to catch this.
- `toEpochNanos05` — `instant(-9223372037, 145224191)`, one nanosecond past the smallest
  count, answers `Some(9223372036854775807)`.
- `toEpochNanos06` — `minInstant()` answers `Some(0)`. Instants at or below the epoch take
  the other branch, which has no guard at all, so `secondsSinceEpoch * nanosPerSecond()`
  overflows silently.

All three are the same root cause, and the same one behind the `between` failures below: `between` is now defined as the difference of two `toEpochNanos` results.

The 2^63 ns either side of the epoch that *do* have a count are all reported correctly —
`toEpochNanos01`, `02`, `04` and `07` pin that, `07` by round-tripping through
`fromEpochNanoseconds` at both ends — so it is only the range guard that is missing.

### `Between.flix`: the ceiling

`between` is now `toEpochNanos(later) - toEpochNanos(earlier)`, so the missing guard above
reaches it too: an endpoint whose count overflows silently comes back as a wrapped number,
and the subtraction then reports a gap that is not the one asked for. Three cases here are
red for that reason, all written to the documented contract — "the absolute amount of time
between `d1` and `d2`, or `None` when it is too large to fit in a `Duration`":

- `between01` — `between(maxInstant(), maxInstant())` answers `None`. The gap between an
  instant and itself is zero however far from the epoch it sits, but the latest instant has
  no `Int64` count, so there is nothing to subtract. (The same case's `minInstant()` and
  `epoch()` halves pass.)
- `between03` — one nanosecond past the largest gap that fits answers a wrapped negative
  duration instead of `None`.
- `between04` — the earliest instant against the epoch answers `Some(0ns)` for a gap of
  about 9.22e18 seconds.

Two cases outside this directory are red from the same cause: `since01` in
`test/test262/.../prototype/since/float64-representable-integer.flix`, and `between08` in
`test/TestMain/Instant.flix`.

`between06` is the case that was written to fail on purpose, when `between` still did its
own subtraction and turned down any second count over 9223372036. It currently passes,
which is an accident rather than a fix: both endpoints overflow and the two wraps happen to
cancel. It is left as it is, written to the contract.

Giving `toEpochNanos` a working range guard clears every case above except `between01` and
`between06`. Those two need `between` itself to stop going through absolute epoch counts:
the gap between two instants can fit in a `Duration` while neither endpoint fits in an
`Int64` count of nanoseconds from the epoch, which is exactly what both of them ask for.

## Licence

These cases are not derived from test262, so they carry no test262 copyright notice and
are under this repository's own licence.

Five of them do reuse expected values worked out by a test262 case, so that the claim is
checked against numbers pinned elsewhere: `SaturatingAdd.flix` and `SaturatingSub.flix`
(from `prototype/{add,subtract}/basic.js`), `TrySub.flix` (from both), `Between.flix` (the
two dated instants of `prototype/since/add-subtract.js`), and `ToEpochNanos.flix` (the two
counts of `prototype/epochNanoseconds/basic.js`, as round-trip inputs). Each file's doc
comment says so. test262 is under the BSD 3-clause licence, a copy of which is in
`test/test262/LICENSE`.

## Helpers

The instant builders and the assertion wrappers come from `test/test262/harness`, which is
test262's own `temporalHelpers.js`. Sharing it keeps one definition of how an `Instant` is
built and compared across both trees; `Instant` holds a record, so Flix cannot derive
`ToString` for it and it cannot be handed to `Assert.assertEq` directly.
