///
/// Ported from test262
/// `test/built-ins/Temporal/Instant/prototype/subtract/blank-duration.js`
/// (esid: sec-temporal.instant.prototype.subtract).
///
/// `new Temporal.Duration()` with no arguments is the zero duration; `Duration.zero()` here.
///
mod Test262.BuiltIns.Temporal.Instant.Prototype.Subtract.BlankDuration {

    use TemporalHelpers.assertInstantsEqual
    use TemporalHelpers.assertSomeInstant
    use TemporalHelpers.fromNanos
    use TemporalHelpers.instant
    use TemporalHelpers.maxInstant
    use TemporalHelpers.minInstant
    use Time.Duration
    use Time.Instant.saturatingSub
    use Time.Instant.trySub

    /// test262: `new Temporal.Instant(1n).subtract(new Temporal.Duration())` is unchanged.
    @Test
    def subtract01_theZeroDuration_leavesTheInstantUnchanged(): Unit \ Assert =
        assertSomeInstant(expected = instant(0i64, 1), trySub(fromNanos(1i64), Duration.zero()),
                          "result is unchanged")

    ///
    /// The zero duration leaves even the two ends of the range unchanged, rather than
    /// tipping them over by way of the borrow.
    ///
    /// No test262 counterpart: this file only subtracts zero from one instant well inside
    /// the range.
    ///
    @Test
    def subtract02_theZeroDurationAtEitherEnd_leavesTheInstantUnchanged(): Unit \ Assert = {
        assertSomeInstant(expected = minInstant(), trySub(minInstant(), Duration.zero()),
                          "the earliest instant is unchanged");
        assertSomeInstant(expected = maxInstant(), trySub(maxInstant(), Duration.zero()),
                          "the latest instant is unchanged");
        assertInstantsEqual(expected = minInstant(), saturatingSub(minInstant(), Duration.zero()),
                            "the earliest instant is unchanged for saturatingSub")
    }

}
