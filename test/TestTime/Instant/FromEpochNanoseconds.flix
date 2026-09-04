///
/// Tests for `fromEpochNanoseconds` that test262 has no counterpart for.
///
/// They are all about the split into a second count and a non-negative nanosecond-of-second,
/// which does not exist over there: `Temporal.Instant` holds one nanosecond count, so the
/// round trip through it is the identity and there is no borrow to get wrong.
///
/// The instant builders and assertions come from the test262 harness rather than being
/// written out again here.
///
mod TestTime.Instant.FromEpochNanoseconds {

    use TemporalHelpers.assertInstantsEqual
    use TemporalHelpers.instant
    use Time.Instant.fromEpochNanoseconds

    /// One nanosecond either side of the epoch, the smallest counts that show the rounding.
    @Test
    def fromEpochNanoseconds01_oneNanosecondEitherSideOfTheEpoch_roundsTowardsNegativeInfinity(): Unit \ Assert = {
        assertInstantsEqual(expected = instant(0i64, 1), fromEpochNanoseconds(1i64),
                            "one nanosecond after the epoch");
        assertInstantsEqual(expected = instant(-1i64, 999_999_999), fromEpochNanoseconds(-1i64),
                            "one nanosecond before the epoch")
    }

    ///
    /// Cross-checks the splits at the two ends of `Int64` against the nearest whole second:
    /// 854775807 ns below the largest count, and 854775808 ns above the smallest one.
    ///
    @Test
    def fromEpochNanoseconds02_theNearestWholeSecondToEitherEnd_leavesNanoAtZero(): Unit \ Assert = {
        assertInstantsEqual(expected = instant(9_223_372_036i64, 0),
                            fromEpochNanoseconds(Int64.maxValue() - 854_775_807i64),
                            "854775807 ns below the largest nanosecond count");
        assertInstantsEqual(expected = instant(-9_223_372_036i64, 0),
                            fromEpochNanoseconds(Int64.minValue() + 854_775_808i64),
                            "854775808 ns above the smallest nanosecond count")
    }

}
