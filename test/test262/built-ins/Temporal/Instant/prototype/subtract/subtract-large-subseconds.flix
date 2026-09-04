// Copyright (C) 2025 Igalia, S.L. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.Instant; the module doc comment says what changed.
///
/// Ported from test262
/// `test/built-ins/Temporal/Instant/prototype/subtract/subtract-large-subseconds.js`
/// (esid: sec-temporal.instant.prototype.subtract).
///
/// The mirror image of `add/add-large-subseconds.js`: a duration whose sub-second part is
/// large enough to borrow many whole seconds. Each of test262's arguments is written as the
/// nanosecond count it amounts to.
///
/// Not portable: the `milliseconds` and `seconds` cases. `Number.MAX_SAFE_INTEGER`
/// milliseconds is about 9.0e21 nanoseconds and the same count of seconds about 9.0e24, and
/// neither fits in the `Int64` a `Duration` holds — the argument cannot be built, which is
/// not the out-of-range *result* test262 is asserting.
///
mod Test262.BuiltIns.Temporal.Instant.Prototype.Subtract.SubtractLargeSubseconds {

    use TemporalHelpers.assertSomeInstant
    use TemporalHelpers.epoch
    use TemporalHelpers.fromNanos
    use TemporalHelpers.instant
    use Time.Duration
    use Time.Instant.Instant
    use Time.Instant.trySub

    /// test262's `i1`: 1582966647747612578 ns, which is 1582966647 s plus 747612578 ns.
    def i1(): Instant = fromNanos(1_582_966_647_747_612_578i64)

    /// `Number.MAX_SAFE_INTEGER`.
    def maxSafeInteger(): Int64 = 9_007_199_254_740_991i64

    /// test262's `bigNumber`.
    def bigNumber(): Int64 = 9_007_199_254_740_990_976i64

    ///
    /// test262: `i1.subtract({ nanoseconds: MAX_SAFE_INTEGER })` is 1573959448492871587n.
    ///
    /// 1582966647747612578 - 9007199254740991 = 1573959448492871587, which is
    /// 1573959448 s plus 492871587 ns.
    ///
    @Test
    def subtract01_theLargestSafeNanosecondCount_borrowsFromTheSeconds(): Unit \ Assert =
        assertSomeInstant(expected = instant(1_573_959_448i64, 492_871_587),
                          trySub(i1(), Duration.nanoseconds(maxSafeInteger())),
                          "nanoseconds: Number.MAX_SAFE_INTEGER")

    ///
    /// test262: `i1.subtract({ nanoseconds: MIN_SAFE_INTEGER })` is 1591973847002353569n.
    ///
    /// 1582966647747612578 + 9007199254740991 = 1591973847002353569, which is
    /// 1591973847 s plus 2353569 ns.
    ///
    @Test
    def subtract02_theSmallestSafeNanosecondCount_carriesIntoTheSeconds(): Unit \ Assert =
        assertSomeInstant(expected = instant(1_591_973_847i64, 2_353_569),
                          trySub(i1(), Duration.nanoseconds(-maxSafeInteger())),
                          "nanoseconds: Number.MIN_SAFE_INTEGER")

    ///
    /// test262: `i1.subtract({ microseconds: MAX_SAFE_INTEGER })` is -7424232606993378422n.
    ///
    /// 9007199254740991 us is 9007199254740991000 ns, and
    /// 1582966647747612578 - 9007199254740991000 = -7424232606993378422, which is
    /// -7424232607 s plus 6621578 ns.
    ///
    @Test
    def subtract03_theLargestSafeMicrosecondCount_borrowsPastTheEpoch(): Unit \ Assert =
        assertSomeInstant(expected = instant(-7_424_232_607i64, 6_621_578),
                          trySub(i1(), Duration.nanoseconds(9_007_199_254_740_991_000i64)),
                          "microseconds: Number.MAX_SAFE_INTEGER")

    ///
    /// test262: `i1.subtract({ microseconds: MIN_SAFE_INTEGER })` is 10590165902488603578n.
    ///
    /// 1582966647747612578 + 9007199254740991000 = 10590165902488603578, which is
    /// 10590165902 s plus 488603578 ns. The total leaves the `Int64` nanosecond range but
    /// not the `Instant` range, whose seconds are an `Int64` of their own.
    ///
    @Test
    def subtract04_theSmallestSafeMicrosecondCount_carriesPastTheNanosecondRange(): Unit \ Assert =
        assertSomeInstant(expected = instant(10_590_165_902i64, 488_603_578),
                          trySub(i1(), Duration.nanoseconds(-9_007_199_254_740_991_000i64)),
                          "microseconds: Number.MIN_SAFE_INTEGER")

    ///
    /// test262: `i1.subtract({ nanoseconds: bigNumber })` is -7424232606993378398n and
    /// `i1.subtract({ nanoseconds: -bigNumber })` is 10590165902488603554n.
    ///
    /// 1582966647747612578 - 9007199254740990976 = -7424232606993378398
    ///   -> -7424232607 s plus 6621602 ns.
    /// 1582966647747612578 + 9007199254740990976 = 10590165902488603554
    ///   -> 10590165902 s plus 488603554 ns.
    ///
    @Test
    def subtract05_bigNumberNanosecondsEitherWay_movesTheSecondsByOverNineBillion(): Unit \ Assert = {
        assertSomeInstant(expected = instant(-7_424_232_607i64, 6_621_602),
                          trySub(i1(), Duration.nanoseconds(bigNumber())),
                          "nanoseconds: bigNumber");
        assertSomeInstant(expected = instant(10_590_165_902i64, 488_603_554),
                          trySub(i1(), Duration.nanoseconds(-bigNumber())),
                          "nanoseconds: -bigNumber")
    }

    ///
    /// test262: `i2.subtract({ nanoseconds: bigNumber })` is -9007199254740990976n and
    /// `i2.subtract({ nanoseconds: -bigNumber })` is 9007199254740990976n, where `i2` is the epoch.
    ///
    @Test
    def subtract06_bigNumberNanosecondsFromTheEpoch_landsSymmetricallyEitherSide(): Unit \ Assert = {
        assertSomeInstant(expected = instant(-9_007_199_255i64, 259_009_024),
                          trySub(epoch(), Duration.nanoseconds(bigNumber())),
                          "nanoseconds: bigNumber from the epoch");
        assertSomeInstant(expected = instant(9_007_199_254i64, 740_990_976),
                          trySub(epoch(), Duration.nanoseconds(-bigNumber())),
                          "nanoseconds: -bigNumber from the epoch")
    }

}
