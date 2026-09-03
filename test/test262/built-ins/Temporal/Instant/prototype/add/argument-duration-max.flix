///
/// Ported from test262
/// `test/built-ins/Temporal/Instant/prototype/add/argument-duration-max.js`
/// (esid: sec-temporal.instant.prototype.add).
///
/// test262 adds the largest duration `Temporal` accepts — 2400000000 hours, and the same
/// span written in minutes and in seconds — and expects it to reach the end of the range
/// exactly. The largest duration here is instead whatever fits in the `Int64` nanosecond
/// count a `Duration` holds, which is a little over 292 years and nowhere near either end of
/// `Instant`. So what is checked is that the extremes of `Duration` are added exactly rather
/// than overflowing along the way.
///
/// The smallest `Duration` is the case worth having: `Int64.minValue()` nanoseconds has no
/// positive counterpart, so it cannot be negated as a whole, and adding it has to go through
/// its second and nanosecond parts separately.
///
mod Test262.BuiltIns.Temporal.Instant.Prototype.Add.ArgumentDurationMax {

    use TemporalHelpers.assertSomeInstant
    use TemporalHelpers.epoch
    use TemporalHelpers.instant
    use Time.Duration
    use Time.Instant.tryAdd

    ///
    /// The largest `Duration`, 9223372036854775807 ns, is 9223372036 s plus 854775807 ns.
    ///
    @Test
    def add01_theLargestDuration_isAddedExactly(): Unit \ Assert =
        assertSomeInstant(expected = instant(9_223_372_036i64, 854_775_807),
                          tryAdd(epoch(), Duration.nanoseconds(Int64.maxValue())),
                          "the largest duration")

    ///
    /// The smallest `Duration`, -9223372036854775808 ns, is 854775808 ns below -9223372036
    /// seconds, so it lands at -9223372037 s plus 145224192 ns.
    ///
    @Test
    def add02_theSmallestDuration_isAddedExactly(): Unit \ Assert =
        assertSomeInstant(expected = instant(-9_223_372_037i64, 145_224_192),
                          tryAdd(epoch(), Duration.nanoseconds(Int64.minValue())),
                          "the smallest duration")

}
