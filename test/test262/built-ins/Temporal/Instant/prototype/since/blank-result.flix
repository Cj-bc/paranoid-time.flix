///
/// Ported from test262 `test/built-ins/Temporal/Instant/prototype/since/blank-result.js`
/// (esid: sec-temporal.instant.prototype.since).
///
/// test262 asserts a duration with every field zero; `Duration` here is one nanosecond
/// count, so the counterpart is `Duration.zero()`.
///
mod Test262.BuiltIns.Temporal.Instant.Prototype.Since.BlankResult {

    use TemporalHelpers.assertSomeDuration
    use TemporalHelpers.fromNanos
    use Time.Duration
    use Time.Instant.between

    /// test262: `new Temporal.Instant(1n).since(new Temporal.Instant(1n))` is blank.
    @Test
    def since01_twoEqualInstants_yieldTheZeroDuration(): Unit \ Assert =
        assertSomeDuration(expected = Duration.zero(), between(fromNanos(1i64), fromNanos(1i64)),
                           "blank result")

}
