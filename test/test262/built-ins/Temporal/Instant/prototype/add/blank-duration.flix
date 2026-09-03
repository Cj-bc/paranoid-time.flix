///
/// Ported from test262 `test/built-ins/Temporal/Instant/prototype/add/blank-duration.js`
/// (esid: sec-temporal.instant.prototype.add).
///
/// `new Temporal.Duration()` with no arguments is the zero duration; `Duration.zero()` here.
///
mod Test262.BuiltIns.Temporal.Instant.Prototype.Add.BlankDuration {

    use TemporalHelpers.assertInstantsEqual
    use TemporalHelpers.assertSomeInstant
    use TemporalHelpers.fromNanos
    use TemporalHelpers.instant
    use TemporalHelpers.maxInstant
    use TemporalHelpers.minInstant
    use Time.Duration
    use Time.Instant.saturatingAdd
    use Time.Instant.tryAdd

    /// test262: `new Temporal.Instant(1n).add(new Temporal.Duration())` is unchanged.
    @Test
    def add01_theZeroDuration_leavesTheInstantUnchanged(): Unit \ Assert =
        assertSomeInstant(expected = instant(0i64, 1), tryAdd(fromNanos(1i64), Duration.zero()),
                          "result is unchanged")

    ///
    /// The zero duration leaves even the two ends of the range unchanged, rather than
    /// tipping them over by way of the carry.
    ///
    /// No test262 counterpart: this file only adds zero to one instant well inside the range.
    ///
    @Test
    def add02_theZeroDurationAtEitherEnd_leavesTheInstantUnchanged(): Unit \ Assert = {
        assertSomeInstant(expected = minInstant(), tryAdd(minInstant(), Duration.zero()),
                          "the earliest instant is unchanged");
        assertSomeInstant(expected = maxInstant(), tryAdd(maxInstant(), Duration.zero()),
                          "the latest instant is unchanged");
        assertInstantsEqual(expected = maxInstant(), saturatingAdd(maxInstant(), Duration.zero()),
                            "the latest instant is unchanged for saturatingAdd")
    }

}
