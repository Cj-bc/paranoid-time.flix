///
/// Tests for `saturatingOfEpochSecond`, which test262 has no counterpart for.
///
/// Neither half of it has anything to port: `Temporal.Instant` has no second-count
/// constructor at all, and a count outside the range is a throw over there rather than a
/// clamp. For `saturatingOfEpochMilli` the clamping half is pinned by the port in
/// `test/test262/built-ins/Temporal/Instant/fromEpochMilliseconds/limits.flix`; seconds have
/// no such port, so both ends are stated here.
///
/// The function differs from `tryOfEpochSecond` in exactly one way — the nearest end instead
/// of `None` — so the cases are laid out along that seam: in range it answers what it was
/// given, outside it the end it ran into.
///
/// The two ends are derived from `max` and `min` rather than written out, so that the
/// numbers stay stated in the one place `Range.flix` pins them. The instant builder and the
/// assertions come from the test262 harness.
///
mod TestTime.Instant.SaturatingOfEpochSecond {

    use TemporalHelpers.{assertInstantsEqual, assertSaturated, instant, parts}
    use Time.Instant.{max, min, saturatingOfEpochSecond}

    /// The latest whole second in range, 253402214399.
    def latestSecond(): Int64 =
        let (seconds, _) = parts(max());
        seconds

    /// The earliest one, -377705116800.
    def earliestSecond(): Int64 =
        let (seconds, _) = parts(min());
        seconds

    /// A second count in range is the second count of the answer, on both sides of the epoch.
    @Test
    def saturatingOfEpochSecond01_aCountInRange_leavesNanoAtZero(): Unit \ Assert = {
        assertInstantsEqual(expected = instant(0i64, 0), saturatingOfEpochSecond(0i64), "the epoch");
        assertInstantsEqual(expected = instant(1i64, 0), saturatingOfEpochSecond(1i64), "one second after");
        assertInstantsEqual(expected = instant(-1i64, 0), saturatingOfEpochSecond(-1i64), "one second before")
    }

    ///
    /// The last second inside either end is still given as it was, not clamped.
    ///
    /// At the bottom that second is the earliest instant itself. At the top it is not the
    /// latest instant: that one is 999999999 ns into its second, which a whole second count
    /// cannot name, so the answer is the start of the second the range ends in — one that
    /// `max()` would be wrong for.
    ///
    @Test
    def saturatingOfEpochSecond02_theLastSecondInsideEitherEnd_isGivenAsIs(): Unit \ Assert = {
        assertInstantsEqual(expected = min(), saturatingOfEpochSecond(earliestSecond()),
                            "the earliest second in range");
        assertInstantsEqual(expected = instant(latestSecond(), 0), saturatingOfEpochSecond(latestSecond()),
                            "the latest second in range")
    }

    /// One second further out than either end clamps to that end, where `tryOfEpochSecond` fails.
    @Test
    def saturatingOfEpochSecond03_oneSecondOutsideEitherEnd_clampsToThatEnd(): Unit \ Assert = {
        assertSaturated(expected = min(), saturatingOfEpochSecond(earliestSecond() - 1i64),
                        "one second before the earliest instant");
        assertSaturated(expected = max(), saturatingOfEpochSecond(latestSecond() + 1i64),
                        "one second after the latest instant")
    }

    ///
    /// The same from as far outside as an `Int64` second count reaches, about 9.2e18 against
    /// a range of about 3.8e11.
    ///
    /// Nothing is computed from the argument before the range check, so there is no overflow
    /// to rule out on the way; what these pin is that the clamp picks the end the count ran
    /// into rather than the other one.
    ///
    @Test
    def saturatingOfEpochSecond04_theTwoEndsOfInt64_clampToTheNearEnd(): Unit \ Assert = {
        assertSaturated(expected = min(), saturatingOfEpochSecond(Int64.minValue()),
                        "the smallest second count");
        assertSaturated(expected = max(), saturatingOfEpochSecond(Int64.maxValue()),
                        "the largest second count")
    }

}
