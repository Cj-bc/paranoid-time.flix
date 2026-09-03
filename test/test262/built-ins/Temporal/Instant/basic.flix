///
/// Ported from test262 `test/built-ins/Temporal/Instant/basic.js`
/// (esid: sec-temporal.instant, "Basic functionality of the Temporal.Instant constructor").
///
/// The constructor there takes one signed nanosecond count. Here an `Instant` is built
/// from a second count plus a non-negative nanosecond-of-second, so each case restates
/// test262's nanosecond value as that pair and then reads it back out.
///
/// Not portable: the cases that pass a string, a boolean or a non-numeric value to the
/// constructor. `Instant` is a record, so there is no argument coercion to test and no
/// `SyntaxError` to provoke.
///
mod Test262.BuiltIns.Temporal.Instant.Basic {

    use TemporalHelpers.epochMilliseconds
    use TemporalHelpers.epochNanoseconds
    use TemporalHelpers.instant

    ///
    /// test262: `new Temporal.Instant(217175010123456789n).epochNanoseconds` is
    /// `217175010123456789n`.
    ///
    /// 217175010123456789 ns is 217175010 whole seconds plus 123456789 nanoseconds.
    ///
    @Test
    def basic01_afterTheEpoch_holdsTheNanosecondCountItWasBuiltFrom(): Unit \ Assert =
        Assert.assertEq(expected = 217_175_010_123_456_789i64,
                        epochNanoseconds(instant(217_175_010i64, 123_456_789)))

    ///
    /// test262: `new Temporal.Instant(217175010123456789n).epochMilliseconds` is
    /// `217175010123`.
    ///
    @Test
    def basic02_afterTheEpoch_reportsWholeMillisecondsOfIt(): Unit \ Assert =
        Assert.assertEq(expected = 217_175_010_123i64,
                        epochMilliseconds(instant(217_175_010i64, 123_456_789)))

    ///
    /// test262: `new Temporal.Instant(-217175010123456789n).epochNanoseconds` is
    /// `-217175010123456789n`.
    ///
    /// `nano` is never negative, so the pair is one second lower than the truncating
    /// division would give: -217175011 seconds plus 876543211 nanoseconds, which is
    /// -217175011000000000 + 876543211 = -217175010123456789 nanoseconds.
    ///
    @Test
    def basic03_beforeTheEpoch_holdsTheNanosecondCountItWasBuiltFrom(): Unit \ Assert =
        Assert.assertEq(expected = -217_175_010_123_456_789i64,
                        epochNanoseconds(instant(-217_175_011i64, 876_543_211)))

    ///
    /// test262: `new Temporal.Instant(-217175010123456789n).epochMilliseconds` is
    /// `-217175010124`, one millisecond lower than truncation would give.
    ///
    /// -217175011000 + 876 = -217175010124.
    ///
    @Test
    def basic04_beforeTheEpoch_roundsMillisecondsTowardsNegativeInfinity(): Unit \ Assert =
        Assert.assertEq(expected = -217_175_010_124i64,
                        epochMilliseconds(instant(-217_175_011i64, 876_543_211)))

}
