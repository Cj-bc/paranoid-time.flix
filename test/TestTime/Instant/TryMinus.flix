///
/// Tests for `tryMinus` that test262 has no counterpart for.
///
/// `Temporal.Instant.prototype.subtract` throws where `tryMinus` answers `None`, and the cases
/// that exercise that are ports and stay under `test/test262`. What is left here is what
/// follows from this library's own shapes: the borrow out of a two-field instant, the ends of
/// the `Int64` nanosecond count a `Duration` holds, and the fact that `tryMinus` and `tryPlus` are
/// written in terms of the same internal shift with only the sign between them.
///
/// The instant builders and assertions come from the test262 harness rather than being
/// written out again here.
///
mod TestTime.Instant.TryMinus {

    use TemporalHelpers.{assertSomeInstant, epoch, fromNanos, instant
                        , largestInstantPairToNanoseconds}
    use Time.Duration
    use Time.Instant.{Instant, tryPlus, tryMinus, max, min}

    /// 50000 ns after the epoch, the starting point of test262's `prototype/subtract/basic.js`.
    def inst(): Instant = fromNanos(50_000i64)

    /// The 3 ms + 2 us + 1 ns that every case in that file carries: 3002001 ns.
    def subSeconds(): Duration =
        Duration.milliseconds(3) + Duration.microseconds(2) + Duration.nanoseconds(1i64)

    ///
    /// The zero duration leaves even the two ends of the range unchanged, rather than tipping
    /// them over by way of the borrow.
    ///
    @Test
    def tryMinus01_theZeroDurationAtEitherEnd_leavesTheInstantUnchanged(): Unit \ Assert = {
        assertSomeInstant(expected = min(), tryMinus(min(), Duration.zero()),
                          "the earliest instant is unchanged");
        assertSomeInstant(expected = max(), tryMinus(max(), Duration.zero()),
                          "the latest instant is unchanged")
    }

    ///
    /// Subtracting a duration is not adding it: the two disagree for every non-zero duration.
    ///
    /// The expected values are those of test262's `prototype/subtract/basic.js` and
    /// `prototype/add/basic.js` for the same argument.
    ///
    @Test
    def tryMinus02_aNonZeroDuration_isNotAdded(): Unit \ Assert = {
        assertSomeInstant(expected = instant(-1i64, 997_047_999), tryMinus(inst(), subSeconds()),
                          "tryMinus moves backwards");
        assertSomeInstant(expected = instant(0i64, 3_052_001), tryPlus(inst(), subSeconds()),
                          "tryPlus moves forwards")
    }

    ///
    /// The smallest `Duration` reaches exactly one nanosecond further than the largest one,
    /// which is what makes it the only duration whose effect `tryPlus` cannot reproduce with the
    /// opposite sign. `Int64.minValue()` nanoseconds has no positive counterpart, so subtracting
    /// it has to negate the second and nanosecond parts separately.
    ///
    @Test
    def tryMinus03_theSmallestDuration_reachesOneNanosecondPastTheLargest(): Unit \ Assert = {
        let (s, nano) = largestInstantPairToNanoseconds();
        assertSomeInstant(expected = instant(s, nano),
                          tryPlus(epoch(), Duration.nanoseconds(Int64.maxValue())),
                          "adding the largest duration");
        assertSomeInstant(expected = instant(s, nano + 1),
                          tryMinus(epoch(), Duration.nanoseconds(Int64.minValue())),
                          "subtracting the smallest duration")
    }

}
