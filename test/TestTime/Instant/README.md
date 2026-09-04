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

## A case that fails on purpose

`Between.flix::between06` asserts what the documented contract of `between` says — "the
absolute amount of time between `d1` and `d2`, or `None` when it is too large to fit in a
`Duration`" — and the implementation does not meet it.

A gap of 9223372036000000001 ns fits in a `Duration`; it is 854775806 ns under
`Int64.maxValue()`. Spread as 9223372037 whole seconds minus 999999999 nanoseconds, it is
rejected: `between` turns down a second count over 9223372036 before the negative nanosecond
difference is allowed to bring the total back under the ceiling. Concretely,
`between(instant(0, 999_999_999), instant(9_223_372_037, 0))` answers `None` for a gap it
can name.

Every gap not spread across an extra second — including the largest one,
`Int64.maxValue()` ns exactly — is reported correctly, so this is the only shape that trips
it. `between02` and `between03` pin that boundary. The guard exists to stop
`seconds * 1_000_000_000` from overflowing, so a fix has to keep that while letting a
negative nanosecond difference count.

The case is written to the contract rather than to the behaviour, so it stays red until
`between` is fixed.

## Licence

These cases are not derived from test262, so they carry no test262 copyright notice and
are under this repository's own licence.

Four of them do reuse expected values worked out by a test262 case, so that the claim is
checked against numbers pinned elsewhere: `SaturatingAdd.flix` and `SaturatingSub.flix`
(from `prototype/{add,subtract}/basic.js`), `TrySub.flix` (from both), and `Between.flix`
(the two dated instants of `prototype/since/add-subtract.js`). Each file's doc comment says
so. test262 is under the BSD 3-clause licence, a copy of which is in
`test/test262/LICENSE`.

## Helpers

The instant builders and the assertion wrappers come from `test/test262/harness`, which is
test262's own `temporalHelpers.js`. Sharing it keeps one definition of how an `Instant` is
built and compared across both trees; `Instant` holds a record, so Flix cannot derive
`ToString` for it and it cannot be handed to `Assert.assertEq` directly.
