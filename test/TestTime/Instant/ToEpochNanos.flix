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
    use TemporalHelpers.epoch
    use TemporalHelpers.instant
    use TemporalHelpers.largestInstantPairToNanoseconds
    use TemporalHelpers.maxInstant
    use TemporalHelpers.minInstant
    use TemporalHelpers.smallestInstantPairToNanoseconds
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
        Assert.assertEqWithMsg(expected = 0ii, toEpochNanos(epoch()), "the epoch itself");
        Assert.assertEqWithMsg(expected = 1ii, toEpochNanos(instant(0i64, 1)),
                        "one nanosecond after the epoch");
        Assert.assertEqWithMsg(expected = -1ii, toEpochNanos(instant(-1i64, 999_999_999)),
                        "one nanosecond before the epoch");
        Assert.assertEqWithMsg(expected = -1_000_000_000ii, toEpochNanos(instant(-1i64, 0)),
                        "one second before the epoch")
    }

    ///
    /// Every count an `Int64` can hold survives the round trip through the two fields.
    ///
    /// `fromEpochNanoseconds` is total, so this pairs the two directions against each
    /// other: whatever split it chooses, `toEpochNanos` has to undo it exactly, including
    /// at the two ends, where the split borrows a second.
    ///
    @Test
    def toEpochNanos03_aCountSplitAndRecombined_isUnchanged(): Unit \ Assert =
        List.forEach(ns -> Assert.assertEqWithMsg(expected = Int64.toBigInt(ns), toEpochNanos(fromEpochNanoseconds(ns)),
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
