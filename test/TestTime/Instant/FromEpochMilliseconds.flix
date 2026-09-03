///
/// Tests for `fromEpochMilliseconds` that test262 has no counterpart for.
///
/// They are all about the split into a second count and a non-negative nanosecond-of-second,
/// which does not exist over there: `Temporal.Instant` holds one nanosecond count, so it has
/// no borrow to get wrong. test262's own cases only cover counts with a leftover millisecond.
///
/// The instant builders and assertions come from the test262 harness rather than being
/// written out again here.
///
mod TestTime.Instant.FromEpochMilliseconds {

    use TemporalHelpers.assertInstantsEqual
    use TemporalHelpers.instant
    use Time.Instant.fromEpochMilliseconds

    /// A whole number of seconds leaves `nano` at zero on both sides of the epoch.
    @Test
    def fromEpochMilliseconds01_aWholeNumberOfSeconds_leavesNanoAtZero(): Unit \ Assert = {
        assertInstantsEqual(expected = instant(0i64, 0), fromEpochMilliseconds(0i64), "the epoch");
        assertInstantsEqual(expected = instant(1i64, 0), fromEpochMilliseconds(1_000i64), "one second after");
        assertInstantsEqual(expected = instant(-1i64, 0), fromEpochMilliseconds(-1_000i64), "one second before")
    }

    /// One millisecond before the epoch is the smallest count that has to borrow.
    @Test
    def fromEpochMilliseconds02_oneMillisecondBeforeTheEpoch_borrowsASecond(): Unit \ Assert =
        assertInstantsEqual(expected = instant(-1i64, 999_000_000), fromEpochMilliseconds(-1i64),
                            "one millisecond before the epoch")

    ///
    /// Cross-checks the splits at the two ends of `Int64` against the nearest whole second:
    /// 807 ms below the largest count, and 808 ms above the smallest one.
    ///
    /// Reading them back as milliseconds would be the more direct check, but at the smallest
    /// count that multiplication leaves the `Int64` range.
    ///
    @Test
    def fromEpochMilliseconds03_theNearestWholeSecondToEitherEnd_leavesNanoAtZero(): Unit \ Assert = {
        assertInstantsEqual(expected = instant(9_223_372_036_854_775i64, 0),
                            fromEpochMilliseconds(Int64.maxValue() - 807i64),
                            "807 ms below the largest millisecond count");
        assertInstantsEqual(expected = instant(-9_223_372_036_854_775i64, 0),
                            fromEpochMilliseconds(Int64.minValue() + 808i64),
                            "808 ms above the smallest millisecond count")
    }

}
