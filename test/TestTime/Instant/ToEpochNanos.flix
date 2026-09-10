///
/// Tests for `toEpochNanos` that test262 has no counterpart for.
///
/// Two differences account for all of them.
///
/// `Temporal.Instant` *is* a nanosecond count, so `epochNanoseconds` reads a field where
/// this has to put two fields back together — the borrowed second before the epoch, and
/// `nano` staying non-negative on both sides of it, are questions only this form raises.
///
/// And that count is a `BigInt` over there, so it is never out of range. Here it is an
/// `Int64`, whose whole span is a little over +/-9.22e18 nanoseconds — far narrower than
/// `Instant`, which reaches +/-9.22e18 *seconds*. So most of an `Instant`'s range has no
/// count at all and `toEpochNanos` answers `None`, which is the claim `Temporal` has no
/// way to make.
///
/// The instant builders and assertions come from the test262 harness rather than being
/// written out again here. The round trip in `toEpochNanos07` reuses the two counts of
/// test262's `prototype/epochNanoseconds/basic.js` among its inputs, so that the case is
/// anchored to numbers pinned elsewhere as well as to the ends of the range.
///
mod TestTime.Instant.ToEpochNanos {

    use TemporalHelpers.assertNoNanos
    use TemporalHelpers.assertSomeNanos
    use TemporalHelpers.epoch
    use TemporalHelpers.instant
    use TemporalHelpers.maxInstant
    use TemporalHelpers.minInstant
    use Time.Instant.fromEpochNanoseconds
    use Time.Instant.toEpochNanos

    ///
    /// One nanosecond either side of the epoch, the smallest counts that show the two
    /// fields being recombined.
    ///
    /// The instant one nanosecond before the epoch is held as -1 second plus 999999999 ns,
    /// so the second has to be paid back: -1000000000 + 999999999 = -1.
    ///
    @Test
    def toEpochNanos01_oneNanosecondEitherSideOfTheEpoch_recombinesTheTwoFields(): Unit \ Assert = {
        assertSomeNanos(expected = 0i64, toEpochNanos(epoch()), "the epoch itself");
        assertSomeNanos(expected = 1i64, toEpochNanos(instant(0i64, 1)),
                        "one nanosecond after the epoch");
        assertSomeNanos(expected = -1i64, toEpochNanos(instant(-1i64, 999_999_999)),
                        "one nanosecond before the epoch");
        assertSomeNanos(expected = -1_000_000_000i64, toEpochNanos(instant(-1i64, 0)),
                        "one second before the epoch")
    }

    ///
    /// The largest count there is: `Int64.maxValue()` is 9223372036854775807 ns, which is
    /// 9223372036 whole seconds plus 854775807 ns.
    ///
    @Test
    def toEpochNanos02_theLargestCountThatFits_isReported(): Unit \ Assert =
        assertSomeNanos(expected = Int64.maxValue(),
                        toEpochNanos(largestInstantPairToNanoseconds() ||> instant),
                        "the largest count that fits in an Int64")

    /// One nanosecond further and there is no count for it.
    @Test
    def toEpochNanos03_oneNanosecondPastTheLargestCount_hasNoCount(): Unit \ Assert =
        let (s, nano) = largestInstantPairToNanoseconds();
        assertNoNanos(toEpochNanos(instant(s, nano + 1)),
                      "one nanosecond past the largest count that fits")

    ///
    /// The smallest count there is: `Int64.minValue()` is -9223372036854775808 ns, which
    /// with `nano` non-negative is -9223372037 seconds plus 145224192 ns —
    /// -9223372037000000000 + 145224192 = -9223372036854775808.
    ///
    @Test
    def toEpochNanos04_theSmallestCountThatFits_isReported(): Unit \ Assert =
        assertSomeNanos(expected = Int64.minValue(),
                        toEpochNanos(smallestInstantPairToNanoseconds() ||> instant),
                        "the smallest count that fits in an Int64")

    ///
    /// One nanosecond further down and there is no count for it either.
    ///
    /// The step is taken in `nano` rather than in the second count, so this is the one
    /// nanosecond below the floor that a truncating conversion would still let through.
    ///
    @Test
    def toEpochNanos05_oneNanosecondPastTheSmallestCount_hasNoCount(): Unit \ Assert =
        let (s, nano) = smallestInstantPairToNanoseconds();
        assertNoNanos(toEpochNanos(instant(s, nano - 1)),
                      "one nanosecond past the smallest count that fits")

    ///
    /// The two ends of `Instant` itself are about 9.22e18 *seconds* from the epoch, a
    /// billion times further out than any `Int64` count reaches, so neither has one.
    ///
    @Test
    def toEpochNanos06_theEndsOfTheInstantRange_haveNoCount(): Unit \ Assert = {
        assertNoNanos(toEpochNanos(maxInstant()), "the latest instant");
        assertNoNanos(toEpochNanos(minInstant()), "the earliest instant")
    }

    ///
    /// Every count an `Int64` can hold survives the round trip through the two fields.
    ///
    /// `fromEpochNanoseconds` is total, so this pairs the two directions against each
    /// other: whatever split it chooses, `toEpochNanos` has to undo it exactly, including
    /// at the two ends, where the split borrows a second.
    ///
    @Test
    def toEpochNanos07_aCountSplitAndRecombined_isUnchanged(): Unit \ Assert =
        List.forEach(ns -> assertSomeNanos(expected = ns, toEpochNanos(fromEpochNanoseconds(ns)),
                                           "the round trip through the two fields"),
                     List#{
                       Int64.minValue(),
                       Int64.minValue() + 1i64,
                       -217_175_010_876_543_211i64,
                       -1_000_000_000i64,
                       -1i64,
                       0i64,
                       1i64,
                       1_000_000_000i64,
                       217_175_010_123_456_789i64,
                       Int64.maxValue() - 1i64,
                       Int64.maxValue()})
}
