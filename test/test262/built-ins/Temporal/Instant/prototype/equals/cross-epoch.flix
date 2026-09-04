// Copyright (C) 2018 Bloomberg LP. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.Instant; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/Instant/prototype/equals/cross-epoch.js`
/// (esid: sec-temporal.instant.prototype.equals).
///
/// The same three timestamps as `compare/cross-epoch.js`, spelled out as the
/// (second, nanosecond-of-second) pairs they denote:
///
///   1963-02-13T09:36:29.123456789Z -> (-217175011, 123456789)
///   1976-11-18T15:23:30.123456789Z -> ( 217178610, 123456789)
///   1981-12-15T14:34:31.987654321Z -> ( 377274871, 987654321)
///
/// The first two share a `nano` and differ only in their second count, one either side of
/// the epoch.
///
mod Test262.BuiltIns.Temporal.Instant.Prototype.Equals.CrossEpoch {

    use TemporalHelpers.instant
    use Time.Instant.Instant

    /// 1963-02-13T09:36:29.123456789Z, before the epoch.
    def i1(): Instant = instant(-217_175_011i64, 123_456_789)

    /// 1976-11-18T15:23:30.123456789Z.
    def i2(): Instant = instant(217_178_610i64, 123_456_789)

    /// 1981-12-15T14:34:31.987654321Z.
    def i3(): Instant = instant(377_274_871i64, 987_654_321)

    /// test262: "pre epoch equal".
    @Test
    def equals01_aPreEpochInstantAgainstItself_isEqual(): Unit \ Assert =
        Assert.assertTrueWithMsg(i1() == i1(), "i1 equals i1")

    /// test262: "epoch equal".
    @Test
    def equals02_aPostEpochInstantAgainstItself_isEqual(): Unit \ Assert =
        Assert.assertTrueWithMsg(i2() == i2(), "i2 equals i2")

    /// test262: "cross epoch unequal".
    @Test
    def equals03_instantsEitherSideOfTheEpoch_areNotEqual(): Unit \ Assert =
        Assert.assertFalseWithMsg(i1() == i2(), "i1 equals i2")

    /// test262: "epoch unequal".
    @Test
    def equals04_twoPostEpochInstants_areNotEqual(): Unit \ Assert =
        Assert.assertFalseWithMsg(i2() == i3(), "i2 equals i3")

}
