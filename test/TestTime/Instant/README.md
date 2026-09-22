# `Time.Instant` tests with no test262 counterpart

`test/test262` holds the cases carried over from [tc39/test262][test262]. This directory
holds the rest: assertions about `Time.Instant` that test262 has nothing to say about, one
file per function.

[test262]: https://github.com/tc39/test262

| File | Under test |
| --- | --- |
| `Compare.flix` | `Order[Instant]` |
| `Equals.flix` | `Eq[Instant]` |
| `SaturatingOfEpochMilli.flix` | `saturatingOfEpochMilli` |
| `OfEpochNanos.flix` | `ofEpochNanos` |
| `OfEpochSecond.flix` | `ofEpochSecond` |
| `TryPlus.flix` | `tryPlus` |
| `SaturatingPlus.flix` | `saturatingPlus` |
| `TryMinus.flix` | `tryMinus` |
| `SaturatingMinus.flix` | `saturatingMinus` |
| `ToEpochNanos.flix` | `toEpochNanos` |
| `Between.flix` | `between` |
| `Range.flix` | the two ends of the representable range |

## Why these have no counterpart

Three differences account for all of them.

**`Instant` is two fields.** A second count plus a nanosecond-of-second in
`[0, 999999999]`, where `Temporal.Instant` is a single signed nanosecond count. So the carry
and the borrow between the two fields, `nano` staying non-negative on both sides of the
epoch, and the splits at the two ends of `Int64` are all questions that only arise here.

The range is stated as two calendar instants — -9999-01-02T00:00:00Z to
9999-12-30T23:59:59.999999999Z — and `Temporal` names its own ends by parsing a string,
which `Instant` has no form for. So that the second counts everything else is written
against really are those two dates is a claim only `Range.flix` can make, along with the
reason the ends sit one day inside the four-digit year range rather than on its edge: a UTC
offset has to be able to move an instant by up to 18 hours without leaving it.

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

`ofEpochSecond` has one of its own, and it is the whole of it: `Temporal.Instant` is built
from a millisecond or a nanosecond count and has no second-count constructor at all, so
there is nothing over there to port. Its cases are the two ends and the epoch, because a
whole second count goes into `secondsSinceEpoch` as given — there is no split and no carry
to get wrong — and the range check is the only thing left that can fail. An `Int64` second
count overshoots both ends by about seven orders of magnitude, so both are reachable from
the argument type and each is checked from both sides.

`toEpochNanos` has one of its own: it answers a `BigInt`, as `epochNanoseconds` does, so
the count never runs out of room and the whole question is how the two stored fields are
put back together — including the `nano` that pays back the borrowed second before the
epoch, which is a question only this form raises.

## What the boundary cases pin

`between` has to reach the end of the `Int64` nanosecond line without overflowing on the
way, and it can fail there in three distinguishable ways. Its cases are laid out to
separate them, because a guard that catches one can miss the others:

| Shape | `between` |
| --- | --- |
| exactly at the end | `02` |
| one nanosecond past — the *sum* runs over | `03` |
| one whole second past — the *multiplication* overflows first | `04` |
| far past, at the ends of `Instant` itself | `05` |

The third row is the one an implementation is most likely to miss: `seconds *
nanosPerSecond()` overflows before the nanosecond part is added at all, so a guard written
only against the total never sees it. The end second is reached by walking in from
`Int64.maxValue()` rather than multiplying out.

`between` has a fourth shape of its own, `between07`: a gap that fits in a `Duration` while
*neither end of it* has an `Int64` count from the epoch. It is spread as 9223372037 whole
seconds minus 999999999 nanoseconds, so the borrow has to bring the second count back under
the ceiling before it is measured against it. Taking the gap as the difference of two
`toEpochNanos` results cannot answer it, which is why `between` subtracts field by field.
`between01` is the degenerate case of the same thing: the gap between an instant and itself
is zero however far from the epoch it sits.

Each guard was checked by mutation rather than by inspection — inverting or loosening any
one of them by a single nanosecond or second turns at least one case red.

## Licence

These cases are not derived from test262, so they carry no test262 copyright notice and
are under this repository's own licence.

Five of them do reuse expected values worked out by a test262 case, so that the claim is
checked against numbers pinned elsewhere: `SaturatingPlus.flix` and `SaturatingMinus.flix`
(from `prototype/{add,subtract}/basic.js`), `TryMinus.flix` (from both), `Between.flix` (the
two dated instants of `prototype/since/add-subtract.js`), and `ToEpochNanos.flix` (the two
counts of `prototype/epochNanoseconds/basic.js`, as round-trip inputs). Each file's doc
comment says so. test262 is under the BSD 3-clause licence, a copy of which is in
`test/test262/LICENSE`.

## Helpers

The instant builders and the assertion wrappers come from `test/test262/harness`, which is
test262's own `temporalHelpers.js`. Sharing it keeps one definition of how an `Instant` is
built and compared across both trees; `Instant` holds a record, so Flix cannot derive
`ToString` for it and it cannot be handed to `Assert.assertEq` directly.

The two ends of the countable range are named there too, as
`largestInstantPairToNanoseconds` and `smallestInstantPairToNanoseconds`, as are the two
ends of `Instant` itself, rather than written out at each call site. Cases a fixed distance
from an end derive it — `nano + 1`, `seconds + 1`, or `parts(max())` — so that the
boundary is stated once and every case that reaches for it says which side of it, and how
far, it means to be. `Range.flix` is the one place the numbers are spelled out, because
naming them is what it is for.

`OfEpochNanos.flix` is the exception: its two cases are *about* the offsets
854775807 and 854775808, which is what the doc comment cross-checks, and both already enter
through `Int64.maxValue()` / `Int64.minValue()`. Restating them through the pair helpers
would hide the subject of the case behind the arithmetic.
