///
/// Tests for `Time.Instant.now`.
///
/// `now` is the only function with an effect, so every test installs its own
/// `Clock` handler instead of reading the real wall clock. That keeps the
/// results deterministic and lets us observe exactly what `now` asks the clock
/// for.
///
mod Time.Instant.Now {
    use Time.Instant.Harness.millisOf
    use Time.TimeUnit

    /// `now` returns the clock reading unchanged.
    @Test
    def now01_returnsTheClockReading(): Unit \ Assert =
        let actual = run {
            Time.Instant.now()
        } with handler Time.Clock.Clock {
            def currentTime(_u, k) = k(1_735_689_600_000i64)
        };
        Assert.assertEq(expected = 1_735_689_600_000i64, millisOf(actual))

    /// The epoch itself is not special-cased away.
    @Test
    def now02_epoch(): Unit \ Assert =
        let actual = run {
            Time.Instant.now()
        } with handler Time.Clock.Clock {
            def currentTime(_u, k) = k(0i64)
        };
        Assert.assertEq(expected = 0i64, millisOf(actual))

    /// Clock readings from before the epoch are carried through as-is.
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

    /// `now` reads the clock exactly once per call.
    @Test
    def now05_readsTheClockOncePerCall(): Unit \ Assert =
        let readings = run {
            let a = Time.Instant.now();
            let b = Time.Instant.now();
            (millisOf(a), millisOf(b))
        } with handler Time.Clock.Clock {
            def currentTime(_u, k) = k(7i64)
        };
        Assert.assertEq(expected = (7i64, 7i64), readings)
}
