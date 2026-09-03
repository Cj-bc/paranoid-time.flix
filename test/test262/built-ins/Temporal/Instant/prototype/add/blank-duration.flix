///
/// Ported from test262 `test/built-ins/Temporal/Instant/prototype/add/blank-duration.js`
/// (esid: sec-temporal.instant.prototype.add).
///
/// `new Temporal.Duration()` with no arguments is the zero duration; `Duration.zero()` here.
///
mod Test262.BuiltIns.Temporal.Instant.Prototype.Add.BlankDuration {

    use TemporalHelpers.assertSomeInstant
    use TemporalHelpers.fromNanos
    use TemporalHelpers.instant
    use Time.Duration
    use Time.Instant.tryAdd

    /// test262: `new Temporal.Instant(1n).add(new Temporal.Duration())` is unchanged.
    @Test
    def add01_theZeroDuration_leavesTheInstantUnchanged(): Unit \ Assert =
        assertSomeInstant(expected = instant(0i64, 1), tryAdd(fromNanos(1i64), Duration.zero()),
                          "result is unchanged")

}
