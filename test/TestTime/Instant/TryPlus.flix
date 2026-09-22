///
/// Tests for `tryPlus` that test262 has no counterpart for.
///
/// `Temporal.Instant.prototype.add` throws where `tryPlus` answers `None`, and the cases that
/// exercise that are ports and stay under `test/test262`. What is left here is what follows
/// from this library's own shapes: the carry out of a two-field instant, and the ends of the
/// `Int64` nanosecond count a `Duration` holds, which is far narrower than the `Instant` range
/// and has no counterpart in `Temporal.Duration`.
///
/// The instant builders and assertions come from the test262 harness rather than being
/// written out again here.
///
mod TestTime.Instant.TryPlus {

    use TemporalHelpers.{assertSomeInstant, instant}
    use Time.Duration
    use Time.Instant.{tryPlus, max, min}

    ///
    /// The zero duration leaves even the two ends of the range unchanged, rather than tipping
    /// them over by way of the carry.
    ///
    @Test
    def tryPlus01_theZeroDurationAtEitherEnd_leavesTheInstantUnchanged(): Unit \ Assert = {
        assertSomeInstant(expected = min(), tryPlus(min(), Duration.zero()),
                          "the earliest instant is unchanged");
        assertSomeInstant(expected = max(), tryPlus(max(), Duration.zero()),
                          "the latest instant is unchanged")
    }

    ///
    /// Neither extreme of `Duration` comes anywhere near an end of the range, so both succeed
    /// from an instant that is itself far from the epoch.
    ///
    @Test
    def tryPlus02_theTwoDurationExtremesFromAFarOffInstant_stayInRange(): Unit \ Assert = {
        let t = instant(100_000_000_000i64, 500_000_000);
        // 100000000000 + 9223372036 = 109223372036 s, and 500000000 + 854775807 carries
        // one second, leaving 354775807 ns.
        assertSomeInstant(expected = instant(109_223_372_037i64, 354_775_807),
                          tryPlus(t, Duration.nanoseconds(Int64.maxValue())),
                          "the largest duration from a far off instant");
        // 100000000000 - 9223372037 = 90776627963 s, and 500000000 + 145224192 = 645224192 ns.
        assertSomeInstant(expected = instant(90_776_627_963i64, 645_224_192),
                          tryPlus(t, Duration.nanoseconds(Int64.minValue())),
                          "the smallest duration from a far off instant")
    }

}
