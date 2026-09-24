// Copyright (C) 2022 André Bargull. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.Instant; the module doc comment says what changed.
///
/// Ported from test262
/// `test/built-ins/Temporal/Instant/prototype/add/minimum-maximum-instant.js`
/// (esid: sec-temporal.instant.prototype.add).
///
/// The two ends are different here — -9999-01-02T00:00:00Z and
/// 9999-12-30T23:59:59.999999999Z, with `nano` at 0 at the bottom and at 999999999 at the
/// top — but the shape of the file carries over: adding zero leaves an end alone, one
/// nanosecond inwards is fine, and one nanosecond outwards is not.
///
/// Each `RangeError` becomes two cases: `tryPlus` answers `None`, and `saturatingPlus` answers
/// the end it ran into.
///
/// Not portable: test262's closing block, which walks from one end of the range to the other
/// in a single `add`. The gap here is about 6.3e11 seconds and a `Duration` tops out at
/// roughly 9.2e9 seconds, so no single duration spans it.
///
mod Test262.BuiltIns.Temporal.Instant.Prototype.Add.MinimumMaximumInstant {

    use TemporalHelpers.{assertNoInstant, assertSaturated, assertSomeInstant, instant, parts}
    use Time.Duration
    use Time.Instant.{saturatingPlus, tryPlus, max, min}

    /// test262's `one`.
    def one(): Duration = Duration.nanoseconds(1i64)

    /// test262's `minusOne`.
    def minusOne(): Duration = Duration.nanoseconds(-1i64)

    /// test262: "Adding zero to the minimum instant".
    @Test
    def add01_zeroAtTheEarliestInstant_leavesItThere(): Unit \ Assert =
        assertSomeInstant(expected = min(), tryPlus(min(), Duration.zero()),
                          "adding zero to the minimum instant")

    /// test262: "Adding zero to the maximum instant".
    @Test
    def add02_zeroAtTheLatestInstant_leavesItThere(): Unit \ Assert =
        assertSomeInstant(expected = max(), tryPlus(max(), Duration.zero()),
                          "adding zero to the maximum instant")

    ///
    /// test262: "Subtracting one from the minimum instant" throws.
    ///
    /// `nano` is already 0 at the earliest instant, so one nanosecond down borrows a second
    /// that the second count has no room for.
    ///
    @Test
    def add03_minusOneNanosecondAtTheEarliestInstant_isOutOfRange(): Unit \ Assert = {
        assertNoInstant(tryPlus(min(), minusOne()), "subtracting one from the minimum instant");
        assertSaturated(expected = min(), saturatingPlus(min(), minusOne()),
                        "subtracting one from the minimum instant")
    }

    ///
    /// test262: "Adding one to the maximum instant" throws.
    ///
    /// `nano` is already at 999999999, so one nanosecond up carries into a second the second
    /// count has no room for.
    ///
    @Test
    def add04_oneNanosecondAtTheLatestInstant_isOutOfRange(): Unit \ Assert = {
        assertNoInstant(tryPlus(max(), one()), "adding one to the maximum instant");
        assertSaturated(expected = max(), saturatingPlus(max(), one()),
                        "adding one to the maximum instant")
    }

    /// test262: "Adding one to the minimum instant" is the minimum instant plus 1n.
    @Test
    def add05_oneNanosecondAtTheEarliestInstant_movesOneNanosecondIn(): Unit \ Assert =
        let (earliestSecond, _) = parts(min());
        assertSomeInstant(expected = instant(earliestSecond, 1), tryPlus(min(), one()),
                          "adding one to the minimum instant")

    /// test262: "Subtracting one from the maximum instant" is the maximum instant minus 1n.
    @Test
    def add06_minusOneNanosecondAtTheLatestInstant_movesOneNanosecondIn(): Unit \ Assert =
        let (latestSecond, _) = parts(max());
        assertSomeInstant(expected = instant(latestSecond, 999_999_998), tryPlus(max(), minusOne()),
                          "subtracting one from the maximum instant")

}
