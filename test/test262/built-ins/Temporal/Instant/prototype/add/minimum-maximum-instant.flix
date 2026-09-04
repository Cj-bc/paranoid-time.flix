// Copyright (C) 2022 André Bargull. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.Instant; the module doc comment says what changed.
///
/// Ported from test262
/// `test/built-ins/Temporal/Instant/prototype/add/minimum-maximum-instant.js`
/// (esid: sec-temporal.instant.prototype.add).
///
/// The two ends are different here — the whole `Int64` second line, with `nano` at 0 at the
/// bottom and at 999999999 at the top — but the shape of the file carries over: adding zero
/// leaves an end alone, one nanosecond inwards is fine, and one nanosecond outwards is not.
///
/// Each `RangeError` becomes two cases: `tryAdd` answers `None`, and `saturatingAdd` answers
/// the end it ran into.
///
/// Not portable: test262's closing block, which walks from one end of the range to the other
/// in a single `add`. The gap here is about 1.8e19 seconds and a `Duration` tops out at
/// roughly 9.2e9 seconds, so no single duration spans it.
///
mod Test262.BuiltIns.Temporal.Instant.Prototype.Add.MinimumMaximumInstant {

    use TemporalHelpers.assertNoInstant
    use TemporalHelpers.assertSaturated
    use TemporalHelpers.assertSomeInstant
    use TemporalHelpers.instant
    use TemporalHelpers.maxInstant
    use TemporalHelpers.minInstant
    use Time.Duration
    use Time.Instant.saturatingAdd
    use Time.Instant.tryAdd

    /// test262's `one`.
    def one(): Duration = Duration.nanoseconds(1i64)

    /// test262's `minusOne`.
    def minusOne(): Duration = Duration.nanoseconds(-1i64)

    /// test262: "Adding zero to the minimum instant".
    @Test
    def add01_zeroAtTheEarliestInstant_leavesItThere(): Unit \ Assert =
        assertSomeInstant(expected = minInstant(), tryAdd(minInstant(), Duration.zero()),
                          "adding zero to the minimum instant")

    /// test262: "Adding zero to the maximum instant".
    @Test
    def add02_zeroAtTheLatestInstant_leavesItThere(): Unit \ Assert =
        assertSomeInstant(expected = maxInstant(), tryAdd(maxInstant(), Duration.zero()),
                          "adding zero to the maximum instant")

    ///
    /// test262: "Subtracting one from the minimum instant" throws.
    ///
    /// `nano` is already 0 at the earliest instant, so one nanosecond down borrows a second
    /// that the second count has no room for.
    ///
    @Test
    def add03_minusOneNanosecondAtTheEarliestInstant_isOutOfRange(): Unit \ Assert = {
        assertNoInstant(tryAdd(minInstant(), minusOne()), "subtracting one from the minimum instant");
        assertSaturated(expected = minInstant(), saturatingAdd(minInstant(), minusOne()),
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
        assertNoInstant(tryAdd(maxInstant(), one()), "adding one to the maximum instant");
        assertSaturated(expected = maxInstant(), saturatingAdd(maxInstant(), one()),
                        "adding one to the maximum instant")
    }

    /// test262: "Adding one to the minimum instant" is the minimum instant plus 1n.
    @Test
    def add05_oneNanosecondAtTheEarliestInstant_movesOneNanosecondIn(): Unit \ Assert =
        assertSomeInstant(expected = instant(Int64.minValue(), 1), tryAdd(minInstant(), one()),
                          "adding one to the minimum instant")

    /// test262: "Subtracting one from the maximum instant" is the maximum instant minus 1n.
    @Test
    def add06_minusOneNanosecondAtTheLatestInstant_movesOneNanosecondIn(): Unit \ Assert =
        assertSomeInstant(expected = instant(Int64.maxValue(), 999_999_998), tryAdd(maxInstant(), minusOne()),
                          "subtracting one from the maximum instant")

}
