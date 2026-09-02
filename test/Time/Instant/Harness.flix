///
/// Shared helpers for the `Time.Instant` test suite.
///
/// `Instant` holds a record, which Flix cannot derive `ToString` for, so an
/// `Instant` cannot be handed to `Assert.assertEq` directly. These helpers take
/// it apart into the two fields it carries, which keeps the assertions
/// comparable *and* makes a failure report the numbers that actually differ.
///
pub mod Time.Instant.Harness {
    use Time.Instant.Instant

    /// The number of nanoseconds in one second.
    pub def nanosPerSecond(): Int64 = 1_000_000_000i64

    /// Builds an `Instant` from its two fields.
    pub def instantOf(secondsSinceEpoch: Int64, nano: Int32): Instant =
        Instant({secondsSinceEpoch = secondsSinceEpoch, nano = nano})

    /// Exposes the two fields of `t`, so that they can be compared and printed.
    pub def partsOf(t: Instant): (Int64, Int32) =
        let Instant(i) = t;
        (i#secondsSinceEpoch, i#nano)

    /// Lifts `partsOf` over `Option`, for the `try*` functions.
    pub def partsOfOpt(t: Option[Instant]): Option[(Int64, Int32)] = Option.map(partsOf, t)

    /// The instant `1970-01-01T00:00:00Z`.
    pub def epoch(): Instant = instantOf(0i64, 0)

    /// The earliest representable `Instant`.
    pub def minInstant(): Instant = instantOf(Int64.minValue(), 0)

    /// The latest representable `Instant`. `nano` is at its ceiling too, so
    /// there is no room left even for one more nanosecond.
    pub def maxInstant(): Instant = instantOf(Int64.maxValue(), 999_999_999)

    /// Returns the `Instant` that is `nanos` nanoseconds after the epoch.
    /// `nanos` must not be negative.
    pub def epochPlusNanos(nanos: Int64): Instant =
        instantOf(nanos / nanosPerSecond(), Int64.truncateToInt32(Int64.remainder(nanos, nanosPerSecond())))

    /// The latest `Instant` whose distance from the epoch still fits in a `Duration`.
    pub def epochPlusLargestDuration(): Instant = epochPlusNanos(Int64.maxValue())

    /// One nanosecond later than `epochPlusLargestDuration()`: the first distance
    /// from the epoch that no longer fits in a `Duration`.
    pub def epochPastLargestDuration(): Instant =
        let Instant(i) = epochPlusLargestDuration();
        instantOf(i#secondsSinceEpoch, i#nano + 1)
}
