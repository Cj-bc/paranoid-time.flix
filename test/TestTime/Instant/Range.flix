///
/// Tests for the two ends of the `Instant` range that test262 has no counterpart for.
///
/// `Temporal.Instant` ends at +/-8.64e21 nanoseconds, a round number of nanoseconds with no
/// calendar meaning of its own. The range here is stated as two calendar instants instead —
/// -9999-01-02T00:00:00Z and 9999-12-30T23:59:59.999999999Z — so there is something to pin
/// that test262 never asks: that the second counts the library clamps to really are those
/// two instants, and that they sit one day inside the four-digit year range rather than on
/// its edge.
///
/// That one day of slack is what makes the range usable with a UTC offset: every instant in
/// it still names a year in [-9999, 9999] once an offset is applied, and offsets stay well
/// inside the 24 hours of slack. Without it, -9999-01-01T00:00:00Z read at any positive
/// offset would fall in the year -10000, and 9999-12-31T23:59:59Z at any negative one in
/// the year 10000.
///
/// `fromEpochMilliseconds` is how the cases reach the ends: an `Int64` millisecond count
/// runs about four orders of magnitude past both of them, so the saturating form answers
/// the library's own bounds rather than anything restated here. Where exactly those bounds
/// fall to the millisecond is pinned by the port in
/// `test/test262/built-ins/Temporal/Instant/fromEpochMilliseconds/limits.flix`.
///
/// The instant builders and assertions come from the test262 harness rather than being
/// written out again here.
///
mod TestTime.Instant.Range {

    use TemporalHelpers.assertInstantsEqual
    use TemporalHelpers.assertNoDuration
    use TemporalHelpers.assertNoInstant
    use TemporalHelpers.assertSaturated
    use TemporalHelpers.dayOf9999December31st
    use TemporalHelpers.dayOfMinus9999January1st
    use TemporalHelpers.instant
    use TemporalHelpers.maxInstant
    use TemporalHelpers.minInstant
    use TemporalHelpers.secondsPerDay
    use Time.Duration
    use Time.Instant.between
    use Time.Instant.fromEpochMilliseconds
    use Time.Instant.saturatingAdd
    use Time.Instant.tryAdd

    ///
    /// The earliest instant is midnight one day into -9999, not midnight on its first day.
    ///
    /// -4371587 days * 86400 s/day = -377705116800 s, with `nano` at 0.
    ///
    @Test
    def range01_theEarliestInstant_isMidnightOneDayIntoTheFirstYear(): Unit \ Assert = {
        let expected = instant((dayOfMinus9999January1st() + 1i64) * secondsPerDay(), 0);
        assertInstantsEqual(expected = expected, fromEpochMilliseconds(Int64.minValue()),
                            "-9999-01-02T00:00:00Z");
        assertInstantsEqual(expected = expected, minInstant(),
                            "-9999-01-02T00:00:00Z as the harness names it")
    }

    ///
    /// The latest instant is the last nanosecond of the day before the last day of 9999.
    ///
    /// It is written as one nanosecond below the start of 9999-12-31 rather than as the
    /// start of 9999-12-30 plus a day, so that the `nano` ceiling is part of what is said:
    /// 2932896 days * 86400 s/day = 253402214400 s, one second below that is 253402214399,
    /// and `nano` is 999999999.
    ///
    @Test
    def range02_theLatestInstant_isTheLastNanosecondOfTheDayBeforeTheLastDay(): Unit \ Assert = {
        let expected = instant(dayOf9999December31st() * secondsPerDay() - 1i64, 999_999_999);
        assertInstantsEqual(expected = expected, fromEpochMilliseconds(Int64.maxValue()),
                            "9999-12-30T23:59:59.999999999Z");
        assertInstantsEqual(expected = expected, maxInstant(),
                            "9999-12-30T23:59:59.999999999Z as the harness names it")
    }

    ///
    /// An `Instant` built outside the range is reported as outside it, not wrapped back in.
    ///
    /// The record constructor is public, so nothing stops one being built at the far ends of
    /// `Int64`. Shifting from there is where a range check written only against the result
    /// would go wrong: the second count overflows first and lands back inside the range, so
    /// the operation would answer an instant roughly 584 years from the epoch for an argument
    /// nowhere near it.
    ///
    @Test
    def range03_anInstantBuiltOutsideTheRange_doesNotWrapBackIn(): Unit \ Assert = {
        let pastTheTop = instant(Int64.maxValue(), 0);
        let pastTheBottom = instant(Int64.minValue(), 0);
        assertNoInstant(tryAdd(pastTheTop, Duration.seconds(1)), "one second above the largest Int64 second");
        assertNoInstant(tryAdd(pastTheBottom, Duration.seconds(-1)), "one second below the smallest Int64 second");
        assertSaturated(expected = maxInstant(), saturatingAdd(pastTheTop, Duration.seconds(1)),
                        "one second above the largest Int64 second");
        assertSaturated(expected = minInstant(), saturatingAdd(pastTheBottom, Duration.seconds(-1)),
                        "one second below the smallest Int64 second");
        // `between` subtracts the two second counts, which wraps for the same reason.
        assertNoDuration(between(pastTheBottom, pastTheTop), "the two ends of the Int64 second line")
    }

}
