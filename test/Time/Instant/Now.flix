///
/// Tests for `Time.Instant.now`.
///
/// `now` is the only function with an effect, so every test installs its own
/// `Clock` handler instead of reading the real wall clock. That keeps the
/// results deterministic and lets us observe exactly what `now` asks the clock
/// for.
///
/// Every test names the test262 case it was adapted from, or says plainly that it
/// has no counterpart there. References are against test262
/// `7710052` (2026-08-30) and are relative to `test/built-ins/Temporal/`.
///
mod Time.Instant.Now {
    use Time.Instant.Harness.millisOf
    use Time.TimeUnit

    /// `now` returns the clock reading unchanged.
    ///
    /// Adapted from test262 `Temporal/Now/instant/return-value-value.js`, which
    /// checks the returned instant against `Date.now()`. Here the clock is a handler,
    /// so the reading can be an exact value rather than a bracket.
    @Test
    def now01_returnsTheClockReading(): Unit \ Assert =
        let actual = run {
            Time.Instant.now()
        } with handler Time.Clock.Clock {
            def currentTime(_u, k) = k(1_735_689_600_000i64)
        };
        Assert.assertEq(expected = 1_735_689_600_000i64, millisOf(actual))

    /// The epoch itself is not special-cased away.
    ///
    /// No test262 counterpart: test262 cannot pin the clock to a chosen instant.
    /// Handling the `Clock` effect in the test makes the epoch reachable.
    @Test
    def now02_epoch(): Unit \ Assert =
        let actual = run {
            Time.Instant.now()
        } with handler Time.Clock.Clock {
            def currentTime(_u, k) = k(0i64)
        };
        Assert.assertEq(expected = 0i64, millisOf(actual))

    /// Clock readings from before the epoch are carried through as-is.
    ///
    /// No test262 counterpart, for the same reason as `now02`.
    @Test
    def now03_beforeTheEpoch(): Unit \ Assert =
        let actual = run {
            Time.Instant.now()
        } with handler Time.Clock.Clock {
            def currentTime(_u, k) = k(-1_000i64)
        };
        Assert.assertEq(expected = -1_000i64, millisOf(actual))

    /// `Instant` stores milliseconds, so `now` must ask the clock for
    /// milliseconds -- any other unit would silently rescale every instant.
    ///
    /// No direct test262 counterpart: the requested unit is not observable in
    /// JavaScript. `Temporal/Now/instant/return-value-value.js` gets at the same
    /// property indirectly, dividing `epochNanoseconds` by 1e6 before comparing.
    @Test
    def now04_asksTheClockForMilliseconds(): Unit \ Assert =
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
    def now05_eachCallReadsTheClock(): Unit \ Assert =
        let readings = run {
            let a = Time.Instant.now();
            let b = Time.Instant.now();
            (millisOf(a), millisOf(b))
        } with handler Time.Clock.Clock {
            def currentTime(_u, k) = k(7i64)
        };
        Assert.assertEq(expected = (7i64, 7i64), readings)
}
