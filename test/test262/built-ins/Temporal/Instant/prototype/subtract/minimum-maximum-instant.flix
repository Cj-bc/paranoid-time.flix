// Copyright (C) 2022 André Bargull. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.Instant; the module doc comment says what changed.
///
/// Ported from test262
/// `test/built-ins/Temporal/Instant/prototype/subtract/minimum-maximum-instant.js`
/// (esid: sec-temporal.instant.prototype.subtract).
///
/// The mirror image of `add/minimum-maximum-instant.js`. The two ends are different here —
/// -9999-01-02T00:00:00Z and 9999-12-30T23:59:59.999999999Z, with `nano` at 0 at the bottom
/// and at 999999999 at the top — but the shape of the file carries over.
///
/// Each `RangeError` becomes two cases: `tryMinus` answers `None`, and `saturatingMinus` answers
/// the end it ran into.
///
/// Not portable: test262's closing block, which walks from one end of the range to the other
/// in a single `subtract`. The gap here is about 6.3e11 seconds and a `Duration` tops out at
/// roughly 9.2e9 seconds, so no single duration spans it.
///
mod Test262.BuiltIns.Temporal.Instant.Prototype.Subtract.MinimumMaximumInstant {

    use TemporalHelpers.{assertNoInstant, assertSaturated, assertSomeInstant, instant, parts}
    use Time.Duration
    use Time.Instant.{saturatingMinus, tryMinus, max, min}

    /// test262's `one`.
    def one(): Duration = Duration.nanoseconds(1i64)

    /// test262's `minusOne`.
    def minusOne(): Duration = Duration.nanoseconds(-1i64)

    /// test262: subtracting zero from the minimum instant leaves it there.
    @Test
    def subtract01_zeroAtTheEarliestInstant_leavesItThere(): Unit \ Assert =
        assertSomeInstant(expected = min(), tryMinus(min(), Duration.zero()),
                          "subtracting zero from the minimum instant")

    /// test262: subtracting zero from the maximum instant leaves it there.
    @Test
    def subtract02_zeroAtTheLatestInstant_leavesItThere(): Unit \ Assert =
        assertSomeInstant(expected = max(), tryMinus(max(), Duration.zero()),
                          "subtracting zero from the maximum instant")

    ///
    /// test262: "Subtracting one from the minimum instant" throws.
    ///
    /// `nano` is already 0 at the earliest instant, so one nanosecond down borrows a second
    /// that the second count has no room for.
    ///
    @Test
    def subtract03_oneNanosecondAtTheEarliestInstant_isOutOfRange(): Unit \ Assert = {
        assertNoInstant(tryMinus(min(), one()), "subtracting one from the minimum instant");
        assertSaturated(expected = min(), saturatingMinus(min(), one()),
                        "subtracting one from the minimum instant")
    }

    ///
    /// test262: "Adding one to the maximum instant" — written there as subtracting minus one
    /// — throws.
    ///
    @Test
    def subtract04_minusOneNanosecondAtTheLatestInstant_isOutOfRange(): Unit \ Assert = {
        assertNoInstant(tryMinus(max(), minusOne()), "subtracting minus one from the maximum instant");
        assertSaturated(expected = max(), saturatingMinus(max(), minusOne()),
                        "subtracting minus one from the maximum instant")
    }

    /// test262: subtracting minus one from the minimum instant is the minimum instant plus 1n.
    @Test
    def subtract05_minusOneNanosecondAtTheEarliestInstant_movesOneNanosecondIn(): Unit \ Assert =
        let (earliestSecond, _) = parts(min());
        assertSomeInstant(expected = instant(earliestSecond, 1), tryMinus(min(), minusOne()),
                          "subtracting minus one from the minimum instant")

    /// test262: subtracting one from the maximum instant is the maximum instant minus 1n.
    @Test
    def subtract06_oneNanosecondAtTheLatestInstant_movesOneNanosecondIn(): Unit \ Assert =
        let (latestSecond, _) = parts(max());
        assertSomeInstant(expected = instant(latestSecond, 999_999_998), tryMinus(max(), one()),
                          "subtracting one from the maximum instant")

}
