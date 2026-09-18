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

    use TemporalHelpers.{assertInstantsEqual, instant}
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
    /// The borrow still happens at the far end of the range, where the counts are largest.
    ///
    /// One millisecond after the earliest instant is the case: -377705116799999 ms divides
    /// to -377705116800 whole seconds with 1 ms left over, so the second count is the same
    /// as the earliest instant's and only `nano` moves. Where those two ends themselves
    /// fall is pinned by the port in
    /// `test/test262/built-ins/Temporal/Instant/fromEpochMilliseconds/limits.flix`; counts
    /// past them no longer split at all, they clamp.
    ///
    @Test
    def fromEpochMilliseconds03_atEitherEndOfTheRange_stillBorrows(): Unit \ Assert = {
        assertInstantsEqual(expected = instant(-377_705_116_800i64, 1_000_000),
                            fromEpochMilliseconds(-377_705_116_799_999i64),
                            "one millisecond after the earliest instant");
        assertInstantsEqual(expected = instant(253_402_214_399i64, 0),
                            fromEpochMilliseconds(253_402_214_399_000i64),
                            "the last whole second in range")
    }

}
