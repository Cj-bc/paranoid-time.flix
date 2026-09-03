///
/// Tests for `saturatingSub` that test262 has no counterpart for.
///
/// `Temporal.Instant.prototype.subtract` only offers the throwing form, so the cases where
/// `saturatingSub` clamps to an end are the counterpart of a `RangeError` and stay under
/// `test/test262`. What is left here is the other half: what `saturatingSub` does when nothing
/// goes out of range.
///
/// The starting point and arguments are those of test262's `prototype/subtract/basic.js`, so
/// that the agreement is checked on cases whose expected values are pinned there.
///
/// The instant builders and assertions come from the test262 harness rather than being
/// written out again here.
///
mod TestTime.Instant.SaturatingSub {

    use TemporalHelpers.assertInstantsEqual
    use TemporalHelpers.fromNanos
    use TemporalHelpers.instant
    use TemporalHelpers.minInstant
    use Time.Duration
    use Time.Instant.Instant
    use Time.Instant.saturatingSub

    /// 50000 ns after the epoch, the starting point of test262's `prototype/subtract/basic.js`.
    def inst(): Instant = fromNanos(50_000i64)

    /// The 3 ms + 2 us + 1 ns that every case in that file carries: 3002001 ns.
    def subSeconds(): Duration =
        Duration.milliseconds(3) + Duration.microseconds(2) + Duration.nanoseconds(1i64)

    /// The negated form, -3002001 ns.
    def negativeSubSeconds(): Duration =
        Duration.milliseconds(-3) + Duration.microseconds(-2) + Duration.nanoseconds(-1i64)

    /// `saturatingSub` answers what `trySub` answers whenever the result is in range.
    @Test
    def saturatingSub01_aResultInRange_isTheSameAsTrySub(): Unit \ Assert = {
        assertInstantsEqual(expected = instant(-21_905i64, 997_047_999),
                            saturatingSub(inst(),
                                          Duration.hours(6) + Duration.minutes(5) + Duration.seconds(4)
                                            + subSeconds()),
                            "subtract positive hours");
        assertInstantsEqual(expected = instant(21_904i64, 3_052_001),
                            saturatingSub(inst(),
                                          Duration.hours(-6) + Duration.minutes(-5) + Duration.seconds(-4)
                                            + negativeSubSeconds()),
                            "subtract negative hours")
    }

    ///
    /// The zero duration at the earliest instant is left alone rather than clamped, so the
    /// saturation is driven by the arithmetic actually going out of range and not by sitting
    /// on an end.
    ///
    @Test
    def saturatingSub02_theZeroDurationAtTheEarliestInstant_leavesTheInstantUnchanged(): Unit \ Assert =
        assertInstantsEqual(expected = minInstant(), saturatingSub(minInstant(), Duration.zero()),
                            "the earliest instant is unchanged")

}
