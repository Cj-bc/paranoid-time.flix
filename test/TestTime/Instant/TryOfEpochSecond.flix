///
/// Tests for `tryOfEpochSecond`, which test262 has no counterpart for.
///
/// `Temporal.Instant` exposes no second-count constructor at all — it is built from a
/// millisecond or a nanosecond count — so there is nothing over there to port. What is
/// checked here is the whole of what the function does: a second count lands in
/// `secondsSinceEpoch` as given with `nano` left at zero, and the range check is the only
/// thing that can turn it down.
///
/// An `Int64` second count reaches about seven orders of magnitude past either end of the
/// range, so both ends are reachable from the argument type and each is checked from both
/// sides: the end second itself, and one second further out.
///
/// The two ends are derived from `max` and `min` rather than written out, so
/// that the numbers stay stated in the one place `Range.flix` pins them. The instant builder
/// and the assertions come from the test262 harness.
///
mod TestTime.Instant.TryOfEpochSecond {

    use TemporalHelpers.{assertNoInstant, assertSomeInstant, instant, parts}
    use Time.Instant.{max, min, tryOfEpochSecond}

    /// The latest whole second in range, 253402214399.
    def latestSecond(): Int64 =
        let (seconds, _) = parts(max());
        seconds

    /// The earliest one, -377705116800.
    def earliestSecond(): Int64 =
        let (seconds, _) = parts(min());
        seconds

    @Test
    def tryOfEpochSecond01_theEpoch_returnsBothFieldsZero(): Unit \ Assert =
        assertSomeInstant(expected = instant(0i64, 0), tryOfEpochSecond(0i64), "the epoch")

    ///
    /// The last second inside either end has an `Instant`.
    ///
    /// At the bottom that second *is* the earliest instant, whose `nano` is already zero. At
    /// the top it is not the latest instant: that one is 999999999 ns into its second, and a
    /// whole second count cannot name it, so the instant here is the start of the same second
    /// the range ends in.
    ///
    @Test
    def tryOfEpochSecond02_theLastSecondInsideEitherEnd_hasAnInstant(): Unit \ Assert = {
        assertSomeInstant(expected = min(), tryOfEpochSecond(earliestSecond()),
                          "the earliest second in range");
        assertSomeInstant(expected = instant(latestSecond(), 0), tryOfEpochSecond(latestSecond()),
                          "the latest second in range")
    }

    /// One second further out than either end has none.
    @Test
    def tryOfEpochSecond03_oneSecondOutsideEitherEnd_returnsNone(): Unit \ Assert = {
        assertNoInstant(tryOfEpochSecond(earliestSecond() - 1i64),
                        "one second before the earliest instant");
        assertNoInstant(tryOfEpochSecond(latestSecond() + 1i64),
                        "one second after the latest instant")
    }

    ///
    /// The same from as far outside as an `Int64` second count reaches.
    ///
    /// Nothing is computed from the argument before the range check, so these cannot overflow
    /// on the way; they are here because the argument type does reach this far, and a check
    /// written against the wrong field or the wrong end would let them through.
    ///
    @Test
    def tryOfEpochSecond04_theTwoEndsOfInt64_returnNone(): Unit \ Assert = {
        assertNoInstant(tryOfEpochSecond(Int64.minValue()), "the smallest second count");
        assertNoInstant(tryOfEpochSecond(Int64.maxValue()), "the largest second count")
    }

}
