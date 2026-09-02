mod TestTime.Instant {
  use Time.Clock
  use Time.Duration
  use Time.Instant.Instant
  use Time.TimeUnit

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
  def compare01_largerNanoButEarlierSecond_isLessThan(): Unit \ Assert =
    Assert.assertTrue(instant(0i64, 999_999_999) < instant(1i64, 0))

  @Test
  def compare02_beforeTheEpoch_isLessThanTheEpoch(): Unit \ Assert =
    Assert.assertTrue(instant(-1i64, 999_999_999) < instant(0i64, 0))

  @Test
  def compare03_sameSecondAndSmallerNano_isLessThan(): Unit \ Assert =
    Assert.assertTrue(instant(3i64, 1) < instant(3i64, 2))

  @Test
  def eq01_bothFieldsEqual_isTrue(): Unit \ Assert =
    Assert.assertTrue(instant(3i64, 1) == instant(3i64, 1))

  @Test
  def eq02_onlyNanoDiffers_isFalse(): Unit \ Assert =
    Assert.assertTrue(instant(3i64, 1) != instant(3i64, 2))

  //
  // now
  //

  ///
  /// Handles `Clock` with a clock frozen at `epochMilli` milliseconds since the epoch.
  ///
  /// Every unit is answered from that one value, the way `Time.Clock.handle` derives them
  /// from `System.currentTimeMillis()`, so the frozen clock stays consistent across units.
  ///
  def withClockFrozenAt(epochMilli: Int64, f: Unit -> a \ ef): a \ (ef - Clock) =
    run {
      f()
    } with handler Clock {
      def currentTime(u, k) = k(match u {
        case TimeUnit.Days         => epochMilli / 86_400_000i64
        case TimeUnit.Hours        => epochMilli / 3_600_000i64
        case TimeUnit.Microseconds => epochMilli * 1_000i64
        case TimeUnit.Milliseconds => epochMilli
        case TimeUnit.Minutes      => epochMilli / 60_000i64
        case TimeUnit.Nanoseconds  => epochMilli * 1_000_000i64
        case TimeUnit.Seconds      => epochMilli / 1_000i64
      })
    }

  /// Returns the two internal fields of `now()` read from a clock frozen at `epochMilli`.
  def nowFrozenAt(epochMilli: Int64): (Int64, Int32) =
    withClockFrozenAt(epochMilli, () -> parts(Time.Instant.now()))

  ///
  /// `Int64.maxValue()` milliseconds is 9_223_372_036_854_775 whole seconds plus 807
  /// milliseconds, so the split neither overflows nor loses the leftover milliseconds.
  ///
  def latestClockInstant(): Instant = instant(9_223_372_036_854_775i64, 807_000_000)

  ///
  /// `Int64.minValue()` milliseconds is 808 milliseconds short of -9_223_372_036_854_775
  /// whole seconds. Rounding towards negative infinity puts it one second lower, at
  /// -9_223_372_036_854_776 seconds plus the remaining 192 milliseconds.
  ///
  def earliestClockInstant(): Instant = instant(-9_223_372_036_854_776i64, 192_000_000)

  @Test
  def now01_underTheClockHandler_hasWholeMillisecondNano(): Unit \ Assert + IO =
    // `Clock` only offers millisecond resolution, so `nano` is a whole number of milliseconds.
    let (_, nano) = Time.Clock.runWithIO(() -> parts(Time.Instant.now()));
    Assert.assertTrue(0 <= nano and nano <= 999_999_999 and Int32.remainder(nano, 1_000_000) == 0)

  @Test
  def now02_atTheEpoch_returnsBothFieldsZero(): Unit \ Assert =
    Assert.assertEq(expected = parts(epoch()), nowFrozenAt(0i64))

  /// One millisecond before the epoch takes the negative branch of the internal `floorDiv`.
  @Test
  def now03_oneMillisecondBeforeTheEpoch_borrowsASecondIntoTheNano(): Unit \ Assert =
    Assert.assertEq(expected = (-1i64, 999_000_000), nowFrozenAt(-1i64))

  @Test
  def now04_atTheLatestClockValue_splitsItWithoutOverflowing(): Unit \ Assert =
    Assert.assertEq(expected = parts(latestClockInstant()), nowFrozenAt(Int64.maxValue()))

  @Test
  def now05_atTheEarliestClockValue_keepsTheNanoNonNegative(): Unit \ Assert =
    Assert.assertEq(expected = parts(earliestClockInstant()), nowFrozenAt(Int64.minValue()))

  /// Guards the two hand-computed boundary instants against a slip in their arithmetic.
  @Test
  def now06_atEitherClockExtreme_reconstructsTheMillisecondsItWasGiven(): Unit \ Assert =
    let asMillis = t -> {
      let (seconds, nano) = parts(t);
      seconds * 1_000i64 + Int32.toInt64(nano) / 1_000_000i64
    };
    Assert.assertEq(expected = (Int64.maxValue(), Int64.minValue()),
                    (asMillis(latestClockInstant()), asMillis(earliestClockInstant())))

  //
  // tryAdd/saturatingAdd
  //

  @Test
  def tryAdd01_wholeSeconds_addsToSecondsSinceEpoch(): Unit \ Assert =
    Assert.assertEq(expected = Some((3i64, 0)),
                    Time.Instant.tryAdd(epoch(), Duration.seconds(3)) |> Option.map(parts))

  /// Adding nanoseconds carries over into `secondsSinceEpoch`.
  @Test
  def tryAdd02_nanosPastTheNextSecond_carriesIntoSecondsSinceEpoch(): Unit \ Assert =
    Assert.assertEq(expected = Some((1i64, 500_000_000)),
                    Time.Instant.tryAdd(instant(0i64, 750_000_000), Duration.milliseconds(750))
                      |> Option.map(parts))

  /// Adding a negative duration borrows from `secondsSinceEpoch`.
  @Test
  def tryAdd03_negativeDuration_borrowsFromSecondsSinceEpoch(): Unit \ Assert =
    Assert.assertEq(expected = Some((0i64, 750_000_000)),
                    Time.Instant.tryAdd(instant(1i64, 500_000_000), Duration.milliseconds(-750))
                      |> Option.map(parts))

  /// `nano` stays non-negative even before the epoch.
  @Test
  def tryAdd04_negativeDurationCrossingTheEpoch_keepsNanoNonNegative(): Unit \ Assert =
    Assert.assertEq(expected = Some((-1i64, 500_000_000)),
                    Time.Instant.tryAdd(epoch(), Duration.milliseconds(-500)) |> Option.map(parts))

  @Test
  def tryAdd05_reachingTheLatestSecond_returnsThatInstant(): Unit \ Assert =
    Assert.assertEq(expected = Some((Int64.maxValue(), 0)),
                    Time.Instant.tryAdd(instant(Int64.maxValue() - 1i64, 0), Duration.seconds(1))
                      |> Option.map(parts))

  /// Overflowing `secondsSinceEpoch` gives None.
  @Test
  def tryAdd06_pastTheLatestInstant_returnsNone(): Unit \ Assert =
    Assert.assertEq(expected = None, Time.Instant.tryAdd(maxInstant(), Duration.nanoseconds(1i64))
                                       |> Option.map(parts))

  /// A carry alone is enough to overflow.
  @Test
  def tryAdd07_carryPastTheLatestInstant_returnsNone(): Unit \ Assert =
    // The duration is under a second, so only the carry out of `nano` overflows the seconds.
    Assert.assertEq(expected = None,
                    Time.Instant.tryAdd(instant(Int64.maxValue(), 500_000_000), Duration.milliseconds(600))
                      |> Option.map(parts))

  @Test
  def saturatingAdd01_pastTheLatestInstant_returnsTheLatestInstant(): Unit \ Assert =
    Assert.assertEq(expected = parts(maxInstant()),
                    parts(Time.Instant.saturatingAdd(maxInstant(), Duration.days(1))))

  @Test
  def saturatingAdd02_pastTheEarliestInstant_returnsTheEarliestInstant(): Unit \ Assert =
    Assert.assertEq(expected = parts(minInstant()),
                    parts(Time.Instant.saturatingAdd(minInstant(), Duration.days(-1))))

  @Test
  def saturatingAdd03_withinRange_addsTheDuration(): Unit \ Assert =
    Assert.assertEq(expected = (60i64, 0), parts(Time.Instant.saturatingAdd(epoch(), Duration.minutes(1))))

  //
  // trySub/saturatingSub
  //

  @Test
  def trySub01_wholeSeconds_subtractsFromSecondsSinceEpoch(): Unit \ Assert =
    Assert.assertEq(expected = Some((-3i64, 0)),
                    Time.Instant.trySub(epoch(), Duration.seconds(3)) |> Option.map(parts))

  /// Subtracting nanoseconds borrows from `secondsSinceEpoch`.
  @Test
  def trySub02_nanosPastThePreviousSecond_borrowsFromSecondsSinceEpoch(): Unit \ Assert =
    Assert.assertEq(expected = Some((0i64, 750_000_000)),
                    Time.Instant.trySub(instant(1i64, 500_000_000), Duration.milliseconds(750))
                      |> Option.map(parts))

  /// Subtracting a negative duration carries over into `secondsSinceEpoch`.
  @Test
  def trySub03_negativeDuration_carriesIntoSecondsSinceEpoch(): Unit \ Assert =
    Assert.assertEq(expected = Some((1i64, 500_000_000)),
                    Time.Instant.trySub(instant(0i64, 750_000_000), Duration.milliseconds(-750))
                      |> Option.map(parts))

  /// `Int64.minValue()` nanoseconds cannot be negated as a whole, but is still subtracted exactly.
  @Test
  def trySub04_theSmallestDuration_subtractsItExactly(): Unit \ Assert =
    Assert.assertEq(expected = Some(parts(epochPastLargestDuration())),
                    Time.Instant.trySub(epoch(), Duration.nanoseconds(Int64.minValue()))
                      |> Option.map(parts))

  @Test
  def trySub05_pastTheEarliestInstant_returnsNone(): Unit \ Assert =
    Assert.assertEq(expected = None, Time.Instant.trySub(minInstant(), Duration.nanoseconds(1i64))
                                       |> Option.map(parts))

  @Test
  def saturatingSub01_pastTheEarliestInstant_returnsTheEarliestInstant(): Unit \ Assert =
    Assert.assertEq(expected = parts(minInstant()),
                    parts(Time.Instant.saturatingSub(minInstant(), Duration.days(1))))

  @Test
  def saturatingSub02_pastTheLatestInstant_returnsTheLatestInstant(): Unit \ Assert =
    Assert.assertEq(expected = parts(maxInstant()),
                    parts(Time.Instant.saturatingSub(maxInstant(), Duration.days(-1))))

  /// Subtracting a duration undoes adding it.
  @Test
  def trySub06_theDurationJustAdded_returnsTheOriginalInstant(): Unit \ Assert =
    let t = instant(1_735_689_600i64, 123_456_789);
    let d = Duration.milliseconds(1_500);
    Assert.assertEq(expected = Some(parts(t)),
                    Time.Instant.tryAdd(t, d) |> Option.flatMap(u -> Time.Instant.trySub(u, d))
                      |> Option.map(parts))

  //
  // between
  //

  @Test
  def between01_aLaterInstantWithSmallerNano_returnsTheirDifference(): Unit \ Assert =
    Assert.assertEq(expected = Some(Duration.nanoseconds(1_750_000_000i64)),
                    Time.Instant.between(instant(10i64, 500_000_000), instant(12i64, 250_000_000)))

  /// The result does not depend on the order of the arguments.
  @Test
  def between02_theArgumentsInReverseOrder_returnsTheSameDuration(): Unit \ Assert =
    Assert.assertEq(expected = Some(Duration.nanoseconds(1_750_000_000i64)),
                    Time.Instant.between(instant(12i64, 250_000_000), instant(10i64, 500_000_000)))

  @Test
  def between03_theSameInstantTwice_returnsZero(): Unit \ Assert =
    Assert.assertEq(expected = Some(Duration.zero()), Time.Instant.between(epoch(), epoch()))

  /// Sub-second differences are kept, they are no longer truncated to milliseconds.
  @Test
  def between04_oneNanosecondApart_returnsOneNanosecond(): Unit \ Assert =
    Assert.assertEq(expected = Some(Duration.nanoseconds(1i64)),
                    Time.Instant.between(instant(5i64, 1), instant(5i64, 2)))

  @Test
  def between05_instantsAcrossTheEpoch_returnsTheirDifference(): Unit \ Assert =
    Assert.assertEq(expected = Some(Duration.milliseconds(500)),
                    Time.Instant.between(instant(-1i64, 500_000_000), epoch()))

  /// A difference that does not fit in a `Duration` gives None.
  @Test
  def between06_theWholeRepresentableRange_returnsNone(): Unit \ Assert =
    Assert.assertEq(expected = None, Time.Instant.between(minInstant(), maxInstant()))

  /// The largest difference that still fits in a `Duration`.
  @Test
  def between07_theLargestRepresentableDifference_returnsIt(): Unit \ Assert =
    Assert.assertEq(expected = Some(Duration.nanoseconds(Int64.maxValue())),
                    Time.Instant.between(epoch(), epochPlusLargestDuration()))

  /// One nanosecond more does not fit.
  @Test
  def between08_oneNanosecondPastTheLargestDifference_returnsNone(): Unit \ Assert =
    Assert.assertEq(expected = None, Time.Instant.between(epoch(), epochPastLargestDuration()))
}
