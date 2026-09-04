// Copyright (C) 2023 Igalia, S.L. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.Instant; the module doc comment says what changed.
///
/// Ported from test262
/// `test/built-ins/Temporal/Instant/prototype/subtract/argument-duration-max.js`
/// (esid: sec-temporal.instant.prototype.subtract).
///
/// test262 subtracts the largest duration `Temporal` accepts and expects it to reach the end
/// of the range exactly. The largest duration here is instead whatever fits in the `Int64`
/// nanosecond count a `Duration` holds — a little over 292 years, nowhere near either end of
/// `Instant` — so what is checked is that the two extremes are subtracted exactly.
///
/// The smallest `Duration` is the case this file exists for. `Int64.minValue()` nanoseconds
/// has no positive counterpart, so subtracting it cannot be done by negating the whole count;
/// its second and nanosecond parts have to be negated separately, and the result is one
/// nanosecond further out than any duration can reach in the other direction.
///
mod Test262.BuiltIns.Temporal.Instant.Prototype.Subtract.ArgumentDurationMax {

    use TemporalHelpers.assertSomeInstant
    use TemporalHelpers.epoch
    use TemporalHelpers.instant
    use Time.Duration
    use Time.Instant.trySub

    ///
    /// The largest `Duration` is 9223372036854775807 ns. Subtracted from the epoch that is
    /// -9223372036854775807 ns, which is 854775807 ns below -9223372036 seconds, so it lands
    /// at -9223372037 s plus 145224193 ns.
    ///
    @Test
    def subtract01_theLargestDuration_isSubtractedExactly(): Unit \ Assert =
        assertSomeInstant(expected = instant(-9_223_372_037i64, 145_224_193),
                          trySub(epoch(), Duration.nanoseconds(Int64.maxValue())),
                          "the largest duration")

    ///
    /// The smallest `Duration` is -9223372036854775808 ns. Subtracted from the epoch that is
    /// +9223372036854775808 ns — one nanosecond more than the largest `Duration` — which is
    /// 9223372036 s plus 854775808 ns.
    ///
    /// A negation of the whole count would overflow back to itself and land 2^64 nanoseconds
    /// away; negating the second and nanosecond parts separately is what keeps it exact.
    ///
    @Test
    def subtract02_theSmallestDuration_isNegatedPartByPart(): Unit \ Assert =
        assertSomeInstant(expected = instant(9_223_372_036i64, 854_775_808),
                          trySub(epoch(), Duration.nanoseconds(Int64.minValue())),
                          "the smallest duration")

}
