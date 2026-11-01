///
/// Tests for the two ends of the `Instant` range that test262 has no counterpart for.
///
/// `Temporal.Instant` ends at +/-8.64e21 nanoseconds, a round number of nanoseconds with no
/// calendar meaning of its own. The range here is stated as two calendar instants instead —
/// -9999-01-01T00:00:00Z and 9999-12-30T23:59:59.999999999Z — so there is something to pin
/// that test262 never asks: that the second counts the library clamps to really are those
/// two instants. The lower one is the first moment of the four-digit year range, the same
/// day as `LocalDate.min()`; the upper one stops a day short of its last moment, so the
/// whole of 9999-12-31 is outside the range.
///
/// Each end is checked twice over: against `Time.Instant`'s own constant, and against what
/// `saturatingOfEpochMilli` clamps to, since an `Int64` millisecond count runs about four
/// orders of magnitude past both ends. Where exactly those bounds fall to the millisecond
/// is pinned by the port in
/// `test/test262/built-ins/Temporal/Instant/fromEpochMilliseconds/limits.flix`.
///
/// The day counts, the instant builder and the assertions come from the test262 harness
/// rather than being written out again here.
///
mod TestTime.Instant.Range {

    use TemporalHelpers.{assertInstantsEqual, assertNoDuration, assertNoInstant
                        , assertSaturated, dayOf9999December31st
                        , dayOfMinus9999January1st, instant, secondsPerDay}
    use Time.Duration
    use Time.Instant.{between, saturatingOfEpochMilli
                     , saturatingPlus, tryPlus, max, min}

    ///
    /// The earliest instant is midnight on the first day of -9999.
    ///
    /// -4371587 days * 86400 s/day = -377705116800 s, with `nano` at 0.
    ///
    @Test
    def range01_theEarliestInstant_isMidnightOnTheFirstDayOfTheFirstYear(): Unit \ Assert = {
        let expected = instant(dayOfMinus9999January1st() * secondsPerDay(), 0);
        assertInstantsEqual(expected = expected, saturatingOfEpochMilli(Int64.minValue()),
                            "-9999-01-01T00:00:00Z");
        assertInstantsEqual(expected = expected, min(),
                            "-9999-01-01T00:00:00Z as Time.Instant names it")
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
        assertInstantsEqual(expected = expected, saturatingOfEpochMilli(Int64.maxValue()),
                            "9999-12-30T23:59:59.999999999Z");
        assertInstantsEqual(expected = expected, max(),
                            "9999-12-30T23:59:59.999999999Z as Time.Instant names it")
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
        assertNoInstant(tryPlus(pastTheTop, Duration.seconds(1)), "one second above the largest Int64 second");
        assertNoInstant(tryPlus(pastTheBottom, Duration.seconds(-1)), "one second below the smallest Int64 second");
        assertSaturated(expected = max(), saturatingPlus(pastTheTop, Duration.seconds(1)),
                        "one second above the largest Int64 second");
        assertSaturated(expected = min(), saturatingPlus(pastTheBottom, Duration.seconds(-1)),
                        "one second below the smallest Int64 second");
        // `between` subtracts the two second counts, which wraps for the same reason.
        assertNoDuration(between(pastTheBottom, pastTheTop), "the two ends of the Int64 second line")
    }

}
