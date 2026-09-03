///
/// Ported from test262 `test/built-ins/Temporal/Instant/fromEpochMilliseconds/limits.js`
/// (esid: sec-temporal.instant.fromepochmilliseconds, "Min/max range").
///
/// test262 expects a `RangeError` one millisecond outside +/-8640000000000000, because
/// that is where `Temporal.Instant` ends. `fromEpochMilliseconds` here is total: its
/// argument is an `Int64`, and every `Int64` millisecond count lands inside the far wider
/// `Instant` range. So what is left to pin is the split at the two ends of `Int64`, which
/// is where the division is most likely to go wrong.
///
mod Test262.BuiltIns.Temporal.Instant.FromEpochMilliseconds.Limits {

    use TemporalHelpers.assertInstantsEqual
    use TemporalHelpers.instant
    use Time.Instant.fromEpochMilliseconds

    ///
    /// `Int64.maxValue()` is 9223372036854775807 ms: 9223372036854775 whole seconds
    /// plus 807 ms, which is 807000000 ns.
    ///
    @Test
    def fromEpochMilliseconds01_theLargestMillisecondCount_splitsWithoutOverflowing(): Unit \ Assert =
        assertInstantsEqual(expected = instant(9_223_372_036_854_775i64, 807_000_000),
                            fromEpochMilliseconds(Int64.maxValue()),
                            "the largest millisecond count")

    ///
    /// `Int64.minValue()` is -9223372036854775808 ms, which is 808 ms below
    /// -9223372036854775 whole seconds. Rounding towards negative infinity puts it one
    /// second lower still, at -9223372036854776 seconds plus the remaining 192 ms.
    ///
    @Test
    def fromEpochMilliseconds02_theSmallestMillisecondCount_keepsNanoNonNegative(): Unit \ Assert =
        assertInstantsEqual(expected = instant(-9_223_372_036_854_776i64, 192_000_000),
                            fromEpochMilliseconds(Int64.minValue()),
                            "the smallest millisecond count")

    ///
    /// Cross-checks the two hand-computed splits above against the nearest whole second:
    /// 807 ms below the largest count, and 808 ms above the smallest one.
    ///
    /// Reading them back as milliseconds would be the more direct check, but at the
    /// smallest count that multiplication leaves the `Int64` range.
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
