///
/// Ported from test262 `test/built-ins/Temporal/Instant/fromEpochMilliseconds/basic.js`
/// (esid: sec-temporal.instant.fromepochmilliseconds).
///
/// test262 checks the resulting `epochNanoseconds`; here the result is checked as the
/// (second, nanosecond-of-second) pair it is stored in, since that is where the
/// interesting part of the conversion shows up: the milliseconds have to be split, and
/// a negative count has to round towards negative infinity to keep `nano` non-negative.
///
mod Test262.BuiltIns.Temporal.Instant.FromEpochMilliseconds.Basic {

    use TemporalHelpers.assertInstantsEqual
    use TemporalHelpers.instant
    use Time.Instant.fromEpochMilliseconds

    ///
    /// test262: `fromEpochMilliseconds(217175010_123).epochNanoseconds` is
    /// `217175010_123_000_000n`.
    ///
    /// 217175010123 ms is 217175010 whole seconds plus 123 ms, and 123 ms is 123000000 ns.
    ///
    @Test
    def fromEpochMilliseconds01_afterTheEpoch_splitsIntoSecondsAndNanos(): Unit \ Assert =
        assertInstantsEqual(expected = instant(217_175_010i64, 123_000_000),
                            fromEpochMilliseconds(217_175_010_123i64),
                            "fromEpochMilliseconds post epoch")

    ///
    /// test262: `fromEpochMilliseconds(-217175010_876).epochNanoseconds` is
    /// `-217175010_876_000_000n`.
    ///
    /// Truncating would give -217175010 seconds and a negative remainder. Rounding towards
    /// negative infinity borrows a second instead: -217175011 seconds plus the remaining
    /// 124 ms, and -217175011000000000 + 124000000 = -217175010876000000 ns.
    ///
    @Test
    def fromEpochMilliseconds02_beforeTheEpoch_borrowsASecondToKeepNanoNonNegative(): Unit \ Assert =
        assertInstantsEqual(expected = instant(-217_175_011i64, 124_000_000),
                            fromEpochMilliseconds(-217_175_010_876i64),
                            "fromEpochMilliseconds pre epoch")

}
