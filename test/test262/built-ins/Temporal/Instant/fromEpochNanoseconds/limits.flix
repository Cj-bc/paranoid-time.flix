///
/// Ported from test262 `test/built-ins/Temporal/Instant/fromEpochNanoseconds/limits.js`
/// (esid: sec-temporal.instant.fromepochnanoseconds, "Throws a RangeError if the input is
/// not a valid epoch nanoseconds value").
///
/// test262 expects a `RangeError` one nanosecond outside +/-8.64e21. That bound has no
/// counterpart here: the argument is an `Int64`, whose whole range is a little over
/// +/-9.22e18 nanoseconds and therefore lands well inside `Instant`. `fromEpochNanoseconds`
/// is total, so what the two ends of `Int64` pin instead is the split — the negative end in
/// particular, which is where `Int64.minValue()` has no positive counterpart to divide by.
///
mod Test262.BuiltIns.Temporal.Instant.FromEpochNanoseconds.Limits {

    use TemporalHelpers.assertInstantsEqual
    use TemporalHelpers.instant
    use Time.Instant.fromEpochNanoseconds

    ///
    /// `Int64.maxValue()` is 9223372036854775807 ns: 9223372036 whole seconds plus
    /// 854775807 ns.
    ///
    @Test
    def fromEpochNanoseconds01_theLargestNanosecondCount_splitsWithoutOverflowing(): Unit \ Assert =
        assertInstantsEqual(expected = instant(9_223_372_036i64, 854_775_807),
                            fromEpochNanoseconds(Int64.maxValue()),
                            "the largest nanosecond count")

    ///
    /// `Int64.minValue()` is -9223372036854775808 ns, which is 854775808 ns below
    /// -9223372036 whole seconds. Rounding towards negative infinity puts it at
    /// -9223372037 seconds plus the remaining 145224192 ns.
    ///
    @Test
    def fromEpochNanoseconds02_theSmallestNanosecondCount_keepsNanoNonNegative(): Unit \ Assert =
        assertInstantsEqual(expected = instant(-9_223_372_037i64, 145_224_192),
                            fromEpochNanoseconds(Int64.minValue()),
                            "the smallest nanosecond count")

    ///
    /// Cross-checks the two hand-computed splits above against the nearest whole second:
    /// 854775807 ns below the largest count, and 854775808 ns above the smallest one.
    ///
    @Test
    def fromEpochNanoseconds03_theNearestWholeSecondToEitherEnd_leavesNanoAtZero(): Unit \ Assert = {
        assertInstantsEqual(expected = instant(9_223_372_036i64, 0),
                            fromEpochNanoseconds(Int64.maxValue() - 854_775_807i64),
                            "854775807 ns below the largest nanosecond count");
        assertInstantsEqual(expected = instant(-9_223_372_036i64, 0),
                            fromEpochNanoseconds(Int64.minValue() + 854_775_808i64),
                            "854775808 ns above the smallest nanosecond count")
    }

}
