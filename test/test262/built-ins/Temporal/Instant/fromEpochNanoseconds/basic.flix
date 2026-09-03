///
/// Ported from test262 `test/built-ins/Temporal/Instant/fromEpochNanoseconds/basic.js`
/// (esid: sec-temporal.instant.fromepochnanoseconds).
///
/// test262 reads the result back as `epochNanoseconds`, where the round trip is the
/// identity. Here the nanosecond count has to be split across the two fields, so the
/// result is checked as that pair.
///
mod Test262.BuiltIns.Temporal.Instant.FromEpochNanoseconds.Basic {

    use TemporalHelpers.assertInstantsEqual
    use TemporalHelpers.instant
    use Time.Instant.fromEpochNanoseconds

    ///
    /// test262: `fromEpochNanoseconds(217175010_123_456_789n).epochNanoseconds` is
    /// `217175010_123_456_789n`.
    ///
    @Test
    def fromEpochNanoseconds01_afterTheEpoch_splitsIntoSecondsAndNanos(): Unit \ Assert =
        assertInstantsEqual(expected = instant(217_175_010i64, 123_456_789),
                            fromEpochNanoseconds(217_175_010_123_456_789i64),
                            "fromEpochNanoseconds post epoch")

    ///
    /// test262: `fromEpochNanoseconds(-217175010_876_543_211n).epochNanoseconds` is
    /// `-217175010_876_543_211n`.
    ///
    /// Rounding towards negative infinity gives -217175011 seconds, and the remainder
    /// left over is 123456789 ns: -217175011000000000 + 123456789 = -217175010876543211.
    ///
    @Test
    def fromEpochNanoseconds02_beforeTheEpoch_borrowsASecondToKeepNanoNonNegative(): Unit \ Assert =
        assertInstantsEqual(expected = instant(-217_175_011i64, 123_456_789),
                            fromEpochNanoseconds(-217_175_010_876_543_211i64),
                            "fromEpochNanoseconds pre epoch")

    ///
    /// One nanosecond either side of the epoch, the smallest counts that show the
    /// direction of the rounding.
    ///
    /// No test262 counterpart: the borrow only exists because `Instant` is split in two.
    ///
    @Test
    def fromEpochNanoseconds03_oneNanosecondEitherSideOfTheEpoch_roundsTowardsNegativeInfinity(): Unit \ Assert = {
        assertInstantsEqual(expected = instant(0i64, 1), fromEpochNanoseconds(1i64),
                            "one nanosecond after the epoch");
        assertInstantsEqual(expected = instant(-1i64, 999_999_999), fromEpochNanoseconds(-1i64),
                            "one nanosecond before the epoch")
    }

}
