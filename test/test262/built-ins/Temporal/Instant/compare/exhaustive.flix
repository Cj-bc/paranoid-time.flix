// Copyright (C) 2023 Igalia, S.L. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.Instant; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/Instant/compare/exhaustive.js`
/// (esid: sec-temporal.instant.compare).
///
/// `Temporal.Instant.compare` answers 1, -1 or 0. The counterpart here is the hand-written
/// `Order[Instant]` instance, which answers a `Comparison`, so the three test262 results
/// become `GreaterThan`, `LessThan` and `EqualTo`.
///
mod Test262.BuiltIns.Temporal.Instant.Compare.Exhaustive {

    use TemporalHelpers.fromNanos
    use TemporalHelpers.instant

    /// test262: `compare(new Temporal.Instant(1e18n), new Temporal.Instant(5e17n))` is 1.
    @Test
    def compare01_aLaterInstantFirst_isGreaterThan(): Unit \ Assert =
        Assert.assertEq(expected = Comparison.GreaterThan,
                        Order.compare(fromNanos(1_000_000_000_000_000_000i64),
                                      fromNanos(500_000_000_000_000_000i64)))

    ///
    /// test262: `compare(new Temporal.Instant(-1000n), new Temporal.Instant(1000n))` is -1.
    ///
    /// -1000 ns is stored as -1 second plus 999999000 nanoseconds, so the larger `nano`
    /// belongs to the smaller instant here.
    ///
    @Test
    def compare02_anEarlierInstantFirst_isLessThan(): Unit \ Assert =
        Assert.assertEq(expected = Comparison.LessThan,
                        Order.compare(fromNanos(-1_000i64), fromNanos(1_000i64)))

    /// test262: `compare(new Temporal.Instant(123456789n), new Temporal.Instant(123456789n))` is 0.
    @Test
    def compare03_theSameInstantTwice_isEqualTo(): Unit \ Assert =
        Assert.assertEq(expected = Comparison.EqualTo,
                        Order.compare(fromNanos(123_456_789i64), fromNanos(123_456_789i64)))

}
