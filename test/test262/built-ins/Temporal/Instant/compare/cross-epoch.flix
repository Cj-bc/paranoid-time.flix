///
/// Ported from test262 `test/built-ins/Temporal/Instant/compare/cross-epoch.js`
/// (esid: sec-temporal.instant.compare).
///
/// test262 names its three instants as strings; `Instant` has no parser, so each one is
/// spelled out as the (second, nanosecond-of-second) pair it denotes:
///
///   1963-02-13T09:36:29.123456789Z -> (-217175011, 123456789)
///   1976-11-18T15:23:30.123456789Z -> ( 217178610, 123456789)
///   1981-12-15T14:34:31.987654321Z -> ( 377274871, 987654321)
///
/// The first is before the epoch, so its second count is negative while its `nano` stays
/// non-negative — which is what makes it worth comparing against the other two.
///
mod Test262.BuiltIns.Temporal.Instant.Compare.CrossEpoch {

    use TemporalHelpers.instant
    use Time.Instant.Instant

    /// 1963-02-13T09:36:29.123456789Z, before the epoch.
    def i1(): Instant = instant(-217_175_011i64, 123_456_789)

    /// 1976-11-18T15:23:30.123456789Z. Shares its `nano` with `i1`.
    def i2(): Instant = instant(217_178_610i64, 123_456_789)

    /// 1981-12-15T14:34:31.987654321Z.
    def i3(): Instant = instant(377_274_871i64, 987_654_321)

    /// test262: "pre epoch equal".
    @Test
    def compare01_aPreEpochInstantAgainstItself_isEqualTo(): Unit \ Assert =
        Assert.assertEq(expected = Comparison.EqualTo, Order.compare(i1(), i1()))

    /// test262: "epoch equal".
    @Test
    def compare02_aPostEpochInstantAgainstItself_isEqualTo(): Unit \ Assert =
        Assert.assertEq(expected = Comparison.EqualTo, Order.compare(i2(), i2()))

    /// test262: "cross epoch smaller/larger".
    @Test
    def compare03_aPreEpochInstantBeforeAPostEpochOne_isLessThan(): Unit \ Assert =
        Assert.assertEq(expected = Comparison.LessThan, Order.compare(i1(), i2()))

    /// test262: "cross epoch larger/smaller".
    @Test
    def compare04_aPostEpochInstantBeforeAPreEpochOne_isGreaterThan(): Unit \ Assert =
        Assert.assertEq(expected = Comparison.GreaterThan, Order.compare(i2(), i1()))

    /// test262: "epoch smaller/larger".
    @Test
    def compare05_twoPostEpochInstantsInOrder_isLessThan(): Unit \ Assert =
        Assert.assertEq(expected = Comparison.LessThan, Order.compare(i2(), i3()))

    /// test262: "epoch larger/smaller".
    @Test
    def compare06_twoPostEpochInstantsOutOfOrder_isGreaterThan(): Unit \ Assert =
        Assert.assertEq(expected = Comparison.GreaterThan, Order.compare(i3(), i2()))

}
