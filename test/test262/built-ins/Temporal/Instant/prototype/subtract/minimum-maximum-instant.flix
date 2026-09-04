// Copyright (C) 2022 André Bargull. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.Instant; the module doc comment says what changed.
///
/// Ported from test262
/// `test/built-ins/Temporal/Instant/prototype/subtract/minimum-maximum-instant.js`
/// (esid: sec-temporal.instant.prototype.subtract).
///
/// The mirror image of `add/minimum-maximum-instant.js`. The two ends are different here —
/// the whole `Int64` second line, with `nano` at 0 at the bottom and at 999999999 at the
/// top — but the shape of the file carries over.
///
/// Each `RangeError` becomes two cases: `trySub` answers `None`, and `saturatingSub` answers
/// the end it ran into.
///
/// Not portable: test262's closing block, which walks from one end of the range to the other
/// in a single `subtract`. The gap here is about 1.8e19 seconds and a `Duration` tops out at
/// roughly 9.2e9 seconds, so no single duration spans it.
///
mod Test262.BuiltIns.Temporal.Instant.Prototype.Subtract.MinimumMaximumInstant {

    use TemporalHelpers.assertNoInstant
    use TemporalHelpers.assertSaturated
    use TemporalHelpers.assertSomeInstant
    use TemporalHelpers.instant
    use TemporalHelpers.maxInstant
    use TemporalHelpers.minInstant
    use Time.Duration
    use Time.Instant.saturatingSub
    use Time.Instant.trySub

    /// test262's `one`.
    def one(): Duration = Duration.nanoseconds(1i64)

    /// test262's `minusOne`.
    def minusOne(): Duration = Duration.nanoseconds(-1i64)

    /// test262: subtracting zero from the minimum instant leaves it there.
    @Test
    def subtract01_zeroAtTheEarliestInstant_leavesItThere(): Unit \ Assert =
        assertSomeInstant(expected = minInstant(), trySub(minInstant(), Duration.zero()),
                          "subtracting zero from the minimum instant")

    /// test262: subtracting zero from the maximum instant leaves it there.
    @Test
    def subtract02_zeroAtTheLatestInstant_leavesItThere(): Unit \ Assert =
        assertSomeInstant(expected = maxInstant(), trySub(maxInstant(), Duration.zero()),
                          "subtracting zero from the maximum instant")

    ///
    /// test262: "Subtracting one from the minimum instant" throws.
    ///
    /// `nano` is already 0 at the earliest instant, so one nanosecond down borrows a second
    /// that the second count has no room for.
    ///
    @Test
    def subtract03_oneNanosecondAtTheEarliestInstant_isOutOfRange(): Unit \ Assert = {
        assertNoInstant(trySub(minInstant(), one()), "subtracting one from the minimum instant");
        assertSaturated(expected = minInstant(), saturatingSub(minInstant(), one()),
                        "subtracting one from the minimum instant")
    }

    ///
    /// test262: "Adding one to the maximum instant" — written there as subtracting minus one
    /// — throws.
    ///
    @Test
    def subtract04_minusOneNanosecondAtTheLatestInstant_isOutOfRange(): Unit \ Assert = {
        assertNoInstant(trySub(maxInstant(), minusOne()), "subtracting minus one from the maximum instant");
        assertSaturated(expected = maxInstant(), saturatingSub(maxInstant(), minusOne()),
                        "subtracting minus one from the maximum instant")
    }

    /// test262: subtracting minus one from the minimum instant is the minimum instant plus 1n.
    @Test
    def subtract05_minusOneNanosecondAtTheEarliestInstant_movesOneNanosecondIn(): Unit \ Assert =
        assertSomeInstant(expected = instant(Int64.minValue(), 1), trySub(minInstant(), minusOne()),
                          "subtracting minus one from the minimum instant")

    /// test262: subtracting one from the maximum instant is the maximum instant minus 1n.
    @Test
    def subtract06_oneNanosecondAtTheLatestInstant_movesOneNanosecondIn(): Unit \ Assert =
        assertSomeInstant(expected = instant(Int64.maxValue(), 999_999_998), trySub(maxInstant(), one()),
                          "subtracting one from the maximum instant")

}
