///
/// Tests for `Time.Instant.now`.
///
/// `now` is the only function with an effect, so every test installs its own
/// `Clock` handler instead of reading the real wall clock. That keeps the
/// results deterministic and lets us observe exactly what `now` asks the clock
/// for.
///
/// `Clock` reports milliseconds while an `Instant` holds whole seconds plus a
/// non-negative `nano`, so `now`'s real work is splitting one into the other --
/// which is where the cases below concentrate.
///
/// Every test names the test262 case it was adapted from, or says plainly that it
/// has no counterpart there. References are against test262
/// `7710052` (2026-08-30) and are relative to `test/built-ins/Temporal/`.
///
mod Time.Instant.Now {
    use Time.Instant.Harness.{epoch, instantOf, partsOf}
    use Time.TimeUnit

    /// Handles `Clock` with a clock frozen at `epochMilli` milliseconds since the
    /// epoch, answering every unit from that one value so the frozen clock stays
    /// consistent across units.
    def withClockFrozenAt(epochMilli: Int64, f: Unit -> a \ ef): a \ (ef - Time.Clock.Clock) =
        run {
            f()
        } with handler Time.Clock.Clock {
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

    /// The two fields of `now()` read from a clock frozen at `epochMilli`.
    def nowFrozenAt(epochMilli: Int64): (Int64, Int32) =
        withClockFrozenAt(epochMilli, () -> partsOf(Time.Instant.now()))

    /// `now` reports the clock reading, split into seconds and nanoseconds.
    ///
    /// Adapted from test262 `Temporal/Now/instant/return-value-value.js`, which
    /// checks the returned instant against `Date.now()`. Here the clock is a
    /// handler, so the reading can be an exact value rather than a bracket.
    @Test
    def now01_atAWholeSecond_putsItAllInSecondsSinceEpoch(): Unit \ Assert =
        Assert.assertEq(expected = (1_735_689_600i64, 0), nowFrozenAt(1_735_689_600_000i64))

    /// The leftover milliseconds become nanoseconds rather than being dropped.
    ///
    /// Adapted from test262 `Instant/fromEpochMilliseconds/basic.js`, which builds
    /// an instant from a millisecond count with a non-zero sub-second part.
    @Test
    def now02_partWayThroughASecond_keepsTheRemainderInTheNano(): Unit \ Assert =
        Assert.assertEq(expected = (217_175_010i64, 123_000_000), nowFrozenAt(217_175_010_123i64))

    /// The epoch itself is not special-cased away.
    ///
    /// No test262 counterpart: test262 cannot pin the clock to a chosen instant.
    /// Handling the `Clock` effect in the test makes the epoch reachable.
    @Test
    def now03_atTheEpoch_returnsBothFieldsZero(): Unit \ Assert =
        Assert.assertEq(expected = partsOf(epoch()), nowFrozenAt(0i64))

    /// Before the epoch the split rounds towards negative infinity, so a whole
    /// second is borrowed to keep `nano` non-negative.
    ///
    /// Adapted from test262 `Instant/prototype/epochMilliseconds/basic.js`, whose
    /// pre-epoch case (`-217175010_876_543_211n` reported as `-217175010_877`)
    /// pins down the same rounding direction.
    @Test
    def now04_partWayThroughASecondBeforeTheEpoch_borrowsASecond(): Unit \ Assert =
        Assert.assertEq(expected = (-217_175_011i64, 124_000_000), nowFrozenAt(-217_175_010_876i64));
        Assert.assertEq(expected = (-1i64, 0), nowFrozenAt(-1_000i64))

    /// A `nano` is never negative, whatever the clock reads.
    ///
    /// No test262 counterpart: a `Temporal.Instant` is a single signed count of
    /// nanoseconds, so it has no second field that could go negative.
    @Test
    def now05_atAnyClockReading_keepsTheNanoInRange(): Unit \ Assert =
        let readings = List#{
            Int64.minValue(), -217_175_010_876i64, -1_500i64, -1i64,
            0i64, 1i64, 1_500i64, 217_175_010_123i64, Int64.maxValue()
        };
        List.forEach(ms -> {
            let (_, nano) = nowFrozenAt(ms);
            Assert.assertTrueWithMsg(0 <= nano and nano <= 999_999_999,
                                     "the clock reading ${ms} produced the out-of-range nano ${nano}")
        }, readings)

    /// `Instant` counts from the epoch in milliseconds-worth of clock precision,
    /// so `now` must ask the clock for milliseconds -- any other unit would
    /// silently rescale every instant.
    ///
    /// No direct test262 counterpart: the requested unit is not observable in
    /// JavaScript. `Temporal/Now/instant/return-value-value.js` gets at the same
    /// property indirectly, dividing `epochNanoseconds` by 1e6 before comparing.
    @Test
    def now06_readingTheClock_asksForMilliseconds(): Unit \ Assert =
        run {
            let _t = Time.Instant.now();
            ()
        } with handler Time.Clock.Clock {
            def currentTime(u, k) = {
                Assert.assertEq(expected = TimeUnit.Milliseconds, u);
                k(0i64)
            }
        }

    /// A second call goes back to the clock rather than reusing a cached reading.
    ///
    /// Adapted from test262 `Temporal/Now/instant/return-value-distinct.js`. Flix
    /// instants are values, so "two distinct objects" does not apply; what carries
    /// over is that a second call goes to the clock rather than reusing a cached
    /// reading.
    @Test
    def now07_calledTwice_readsTheClockEachTime(): Unit \ Assert =
        let readings = withClockFrozenAt(7_000i64, () -> {
            let a = Time.Instant.now();
            let b = Time.Instant.now();
            (partsOf(a), partsOf(b))
        });
        Assert.assertEq(expected = ((7i64, 0), (7i64, 0)), readings)

    /// The clock's own extremes split without overflowing, and the split is
    /// reversible: turning both back into milliseconds recovers what was given.
    ///
    /// Adapted from test262 `Instant/fromEpochMilliseconds/limits.js`, which pins
    /// down the ends of the range a millisecond count may come from.
    @Test
    def now08_atEitherClockExtreme_splitsWithoutLosingMilliseconds(): Unit \ Assert =
        let asMillis = match (seconds, nano) -> seconds * 1_000i64 + Int32.toInt64(nano) / 1_000_000i64;
        Assert.assertEq(expected = (9_223_372_036_854_775i64, 807_000_000), nowFrozenAt(Int64.maxValue()));
        Assert.assertEq(expected = (-9_223_372_036_854_776i64, 192_000_000), nowFrozenAt(Int64.minValue()));
        Assert.assertEq(expected = Int64.maxValue(), asMillis(nowFrozenAt(Int64.maxValue())));
        Assert.assertEq(expected = Int64.minValue(), asMillis(nowFrozenAt(Int64.minValue())))
}
