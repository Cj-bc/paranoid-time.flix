mod TestTime.Instant {
  use Time.Duration
  use Time.Instant.Instant

  /// Builds an `Instant` from its two internal fields.
  def instant(secondsSinceEpoch: Int64, nano: Int32): Instant =
    Instant({secondsSinceEpoch = secondsSinceEpoch, nano = nano})

  /// Exposes the two internal fields of `t`, so that they can be compared and printed.
  def parts(t: Instant): (Int64, Int32) =
    let Instant(i) = t;
    (i#secondsSinceEpoch, i#nano)

  def epoch(): Instant = instant(0i64, 0)

  def minInstant(): Instant = instant(Int64.minValue(), 0)

  def maxInstant(): Instant = instant(Int64.maxValue(), 999_999_999)

  def nanosPerSecond(): Int64 = 1_000_000_000i64

  /// Returns the `Instant` that is `nanos` nanoseconds after the epoch. `nanos` must not be negative.
  def epochPlusNanos(nanos: Int64): Instant =
    instant(nanos / nanosPerSecond(), Int64.truncateToInt32(Int64.remainder(nanos, nanosPerSecond())))

  /// The latest `Instant` whose distance from the epoch still fits in a `Duration`.
  def epochPlusLargestDuration(): Instant = epochPlusNanos(Int64.maxValue())

  /// One nanosecond later than `epochPlusLargestDuration()`, the first distance that no longer fits.
  /// It is also how far `Int64.minValue()` nanoseconds reaches when subtracted from the epoch,
  /// since negating that duration gives `Int64.maxValue()` plus one nanosecond.
  def epochPastLargestDuration(): Instant =
    let Instant(i) = epochPlusLargestDuration();
    instant(i#secondsSinceEpoch, i#nano + 1)

  //
  // Order/Eq
  //

  @Test
  def compare_largerNanoButEarlierSecond_isLessThan(): Unit \ Assert =
    Assert.assertTrue(instant(0i64, 999_999_999) < instant(1i64, 0))

  @Test
  def compare_beforeTheEpoch_isLessThanTheEpoch(): Unit \ Assert =
    Assert.assertTrue(instant(-1i64, 999_999_999) < instant(0i64, 0))

  @Test
  def compare_sameSecondAndSmallerNano_isLessThan(): Unit \ Assert =
    Assert.assertTrue(instant(3i64, 1) < instant(3i64, 2))

  @Test
  def eq_bothFieldsEqual_isTrue(): Unit \ Assert =
    Assert.assertTrue(instant(3i64, 1) == instant(3i64, 1))

  @Test
  def eq_onlyNanoDiffers_isFalse(): Unit \ Assert =
    Assert.assertTrue(instant(3i64, 1) != instant(3i64, 2))

  //
  // now
  //

  @Test
  def now_underTheClockHandler_hasWholeMillisecondNano(): Unit \ Assert + IO =
    // `Clock` only offers millisecond resolution, so `nano` is a whole number of milliseconds.
    let (_, nano) = Time.Clock.runWithIO(() -> parts(Time.Instant.now()));
    Assert.assertTrue(0 <= nano and nano <= 999_999_999 and Int32.remainder(nano, 1_000_000) == 0)

  //
  // tryAdd/saturatingAdd
  //

  @Test
  def tryAdd_wholeSeconds_addsToSecondsSinceEpoch(): Unit \ Assert =
    Assert.assertEq(expected = Some((3i64, 0)),
                    Time.Instant.tryAdd(epoch(), Duration.seconds(3)) |> Option.map(parts))

  /// Adding nanoseconds carries over into `secondsSinceEpoch`.
  @Test
  def tryAdd_nanosPastTheNextSecond_carriesIntoSecondsSinceEpoch(): Unit \ Assert =
    Assert.assertEq(expected = Some((1i64, 500_000_000)),
                    Time.Instant.tryAdd(instant(0i64, 750_000_000), Duration.milliseconds(750))
                      |> Option.map(parts))

  /// Adding a negative duration borrows from `secondsSinceEpoch`.
  @Test
  def tryAdd_negativeDuration_borrowsFromSecondsSinceEpoch(): Unit \ Assert =
    Assert.assertEq(expected = Some((0i64, 750_000_000)),
                    Time.Instant.tryAdd(instant(1i64, 500_000_000), Duration.milliseconds(-750))
                      |> Option.map(parts))

  /// `nano` stays non-negative even before the epoch.
  @Test
  def tryAdd_negativeDurationCrossingTheEpoch_keepsNanoNonNegative(): Unit \ Assert =
    Assert.assertEq(expected = Some((-1i64, 500_000_000)),
                    Time.Instant.tryAdd(epoch(), Duration.milliseconds(-500)) |> Option.map(parts))

  @Test
  def tryAdd_reachingTheLatestSecond_returnsThatInstant(): Unit \ Assert =
    Assert.assertEq(expected = Some((Int64.maxValue(), 0)),
                    Time.Instant.tryAdd(instant(Int64.maxValue() - 1i64, 0), Duration.seconds(1))
                      |> Option.map(parts))

  /// Overflowing `secondsSinceEpoch` gives None.
  @Test
  def tryAdd_pastTheLatestInstant_returnsNone(): Unit \ Assert =
    Assert.assertEq(expected = None, Time.Instant.tryAdd(maxInstant(), Duration.nanoseconds(1i64))
                                       |> Option.map(parts))

  /// A carry alone is enough to overflow.
  @Test
  def tryAdd_carryPastTheLatestInstant_returnsNone(): Unit \ Assert =
    // The duration is under a second, so only the carry out of `nano` overflows the seconds.
    Assert.assertEq(expected = None,
                    Time.Instant.tryAdd(instant(Int64.maxValue(), 500_000_000), Duration.milliseconds(600))
                      |> Option.map(parts))

  @Test
  def saturatingAdd_pastTheLatestInstant_returnsTheLatestInstant(): Unit \ Assert =
    Assert.assertEq(expected = parts(maxInstant()),
                    parts(Time.Instant.saturatingAdd(maxInstant(), Duration.days(1))))

  @Test
  def saturatingAdd_pastTheEarliestInstant_returnsTheEarliestInstant(): Unit \ Assert =
    Assert.assertEq(expected = parts(minInstant()),
                    parts(Time.Instant.saturatingAdd(minInstant(), Duration.days(-1))))

  @Test
  def saturatingAdd_withinRange_addsTheDuration(): Unit \ Assert =
    Assert.assertEq(expected = (60i64, 0), parts(Time.Instant.saturatingAdd(epoch(), Duration.minutes(1))))

  //
  // trySub/saturatingSub
  //

  @Test
  def trySub_wholeSeconds_subtractsFromSecondsSinceEpoch(): Unit \ Assert =
    Assert.assertEq(expected = Some((-3i64, 0)),
                    Time.Instant.trySub(epoch(), Duration.seconds(3)) |> Option.map(parts))

  /// Subtracting nanoseconds borrows from `secondsSinceEpoch`.
  @Test
  def trySub_nanosPastThePreviousSecond_borrowsFromSecondsSinceEpoch(): Unit \ Assert =
    Assert.assertEq(expected = Some((0i64, 750_000_000)),
                    Time.Instant.trySub(instant(1i64, 500_000_000), Duration.milliseconds(750))
                      |> Option.map(parts))

  /// Subtracting a negative duration carries over into `secondsSinceEpoch`.
  @Test
  def trySub_negativeDuration_carriesIntoSecondsSinceEpoch(): Unit \ Assert =
    Assert.assertEq(expected = Some((1i64, 500_000_000)),
                    Time.Instant.trySub(instant(0i64, 750_000_000), Duration.milliseconds(-750))
                      |> Option.map(parts))

  /// `Int64.minValue()` nanoseconds cannot be negated as a whole, but is still subtracted exactly.
  @Test
  def trySub_theSmallestDuration_subtractsItExactly(): Unit \ Assert =
    Assert.assertEq(expected = Some(parts(epochPastLargestDuration())),
                    Time.Instant.trySub(epoch(), Duration.nanoseconds(Int64.minValue()))
                      |> Option.map(parts))

  @Test
  def trySub_pastTheEarliestInstant_returnsNone(): Unit \ Assert =
    Assert.assertEq(expected = None, Time.Instant.trySub(minInstant(), Duration.nanoseconds(1i64))
                                       |> Option.map(parts))

  @Test
  def saturatingSub_pastTheEarliestInstant_returnsTheEarliestInstant(): Unit \ Assert =
    Assert.assertEq(expected = parts(minInstant()),
                    parts(Time.Instant.saturatingSub(minInstant(), Duration.days(1))))

  @Test
  def saturatingSub_pastTheLatestInstant_returnsTheLatestInstant(): Unit \ Assert =
    Assert.assertEq(expected = parts(maxInstant()),
                    parts(Time.Instant.saturatingSub(maxInstant(), Duration.days(-1))))

  /// Subtracting a duration undoes adding it.
  @Test
  def trySub_theDurationJustAdded_returnsTheOriginalInstant(): Unit \ Assert =
    let t = instant(1_735_689_600i64, 123_456_789);
    let d = Duration.milliseconds(1_500);
    Assert.assertEq(expected = Some(parts(t)),
                    Time.Instant.tryAdd(t, d) |> Option.flatMap(u -> Time.Instant.trySub(u, d))
                      |> Option.map(parts))

  //
  // between
  //

  @Test
  def between_aLaterInstantWithSmallerNano_returnsTheirDifference(): Unit \ Assert =
    Assert.assertEq(expected = Some(Duration.nanoseconds(1_750_000_000i64)),
                    Time.Instant.between(instant(10i64, 500_000_000), instant(12i64, 250_000_000)))

  /// The result does not depend on the order of the arguments.
  @Test
  def between_theArgumentsInReverseOrder_returnsTheSameDuration(): Unit \ Assert =
    Assert.assertEq(expected = Some(Duration.nanoseconds(1_750_000_000i64)),
                    Time.Instant.between(instant(12i64, 250_000_000), instant(10i64, 500_000_000)))

  @Test
  def between_theSameInstantTwice_returnsZero(): Unit \ Assert =
    Assert.assertEq(expected = Some(Duration.zero()), Time.Instant.between(epoch(), epoch()))

  /// Sub-second differences are kept, they are no longer truncated to milliseconds.
  @Test
  def between_oneNanosecondApart_returnsOneNanosecond(): Unit \ Assert =
    Assert.assertEq(expected = Some(Duration.nanoseconds(1i64)),
                    Time.Instant.between(instant(5i64, 1), instant(5i64, 2)))

  @Test
  def between_instantsAcrossTheEpoch_returnsTheirDifference(): Unit \ Assert =
    Assert.assertEq(expected = Some(Duration.milliseconds(500)),
                    Time.Instant.between(instant(-1i64, 500_000_000), epoch()))

  /// A difference that does not fit in a `Duration` gives None.
  @Test
  def between_theWholeRepresentableRange_returnsNone(): Unit \ Assert =
    Assert.assertEq(expected = None, Time.Instant.between(minInstant(), maxInstant()))

  /// The largest difference that still fits in a `Duration`.
  @Test
  def between_theLargestRepresentableDifference_returnsIt(): Unit \ Assert =
    Assert.assertEq(expected = Some(Duration.nanoseconds(Int64.maxValue())),
                    Time.Instant.between(epoch(), epochPlusLargestDuration()))

  /// One nanosecond more does not fit.
  @Test
  def between_oneNanosecondPastTheLargestDifference_returnsNone(): Unit \ Assert =
    Assert.assertEq(expected = None, Time.Instant.between(epoch(), epochPastLargestDuration()))
}
