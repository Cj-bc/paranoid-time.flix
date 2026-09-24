// Copyright (C) 2018 Bloomberg LP. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.Instant; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/Instant/limits.js`
/// (esid: sec-temporal.instant, "Min/max range").
///
/// test262 pins the range at +/-8.64e21 nanoseconds and checks that one nanosecond
/// beyond either end throws a `RangeError`. The range here is a different one —
/// -9999-01-02T00:00:00Z to 9999-12-30T23:59:59.999999999Z, with `nano` at 0 at the
/// bottom and at its ceiling at the top — and there is no validating constructor to make
/// throw, so the ends are pinned through the arithmetic instead: stepping one nanosecond
/// past either end fails.
///
/// Not portable: the two `Temporal.Instant.from` string comparisons, which name the
/// limits as calendar dates. That the second counts used here really are those dates is
/// checked in `test/TestTime/Instant/Range.flix` instead.
///
mod Test262.BuiltIns.Temporal.Instant.Limits {

    use TemporalHelpers.{assertNoInstant, assertSaturated, assertSomeInstant}
    use Time.Duration
    use Time.Instant.{saturatingPlus, saturatingMinus, tryPlus, tryMinus, max, min}

    /// test262: `new Temporal.Instant(limit + 1n)` throws.
    @Test
    def limits01_oneNanosecondAboveTheLatestInstant_isNotRepresentable(): Unit \ Assert =
        assertNoInstant(tryPlus(max(), Duration.nanoseconds(1i64)),
                        "one nanosecond above the latest instant")

    /// test262: `new Temporal.Instant(-limit - 1n)` throws.
    @Test
    def limits02_oneNanosecondBelowTheEarliestInstant_isNotRepresentable(): Unit \ Assert =
        assertNoInstant(tryMinus(min(), Duration.nanoseconds(1i64)),
                        "one nanosecond below the earliest instant")

    ///
    /// The `saturating` half of the two cases above, which test262 has no counterpart for:
    /// `Temporal` only offers the throwing form.
    ///
    @Test
    def limits03_pastEitherEnd_saturatesToThatEnd(): Unit \ Assert = {
        assertSaturated(expected = max(), saturatingPlus(max(), Duration.nanoseconds(1i64)),
                        "one nanosecond above the latest instant");
        assertSaturated(expected = min(), saturatingMinus(min(), Duration.nanoseconds(1i64)),
                        "one nanosecond below the earliest instant")
    }

    /// test262: `new Temporal.Instant(limit)` and `new Temporal.Instant(-limit)` are fine.
    @Test
    def limits04_theEndsThemselves_areRepresentable(): Unit \ Assert = {
        assertSomeInstant(expected = max(), tryPlus(max(), Duration.zero()),
                          "the latest instant");
        assertSomeInstant(expected = min(), tryPlus(min(), Duration.zero()),
                          "the earliest instant")
    }

}
