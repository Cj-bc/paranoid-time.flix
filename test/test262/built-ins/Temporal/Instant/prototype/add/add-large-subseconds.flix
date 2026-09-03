///
/// Ported from test262
/// `test/built-ins/Temporal/Instant/prototype/add/add-large-subseconds.js`
/// (esid: sec-temporal.instant.prototype.add).
///
/// The point of the file is a duration whose sub-second part is large enough to carry many
/// whole seconds. `Time.Duration` is an `Int64` nanosecond count, so each of test262's
/// arguments is written as the nanosecond count it amounts to.
///
/// Not portable: the `milliseconds` and `seconds` cases. `Number.MAX_SAFE_INTEGER`
/// milliseconds is about 9.0e21 nanoseconds and the same count of seconds about 9.0e24, and
/// neither fits in the `Int64` a `Duration` holds. test262 expects a `RangeError` for them
/// because the *result* leaves `Temporal.Instant`; here it is the *argument* that cannot be
/// built, which is not the same claim, so those cases are left out rather than reinterpreted.
///
mod Test262.BuiltIns.Temporal.Instant.Prototype.Add.AddLargeSubseconds {

    use TemporalHelpers.assertSomeInstant
    use TemporalHelpers.epoch
    use TemporalHelpers.fromNanos
    use TemporalHelpers.instant
    use Time.Duration
    use Time.Instant.Instant
    use Time.Instant.tryAdd

    /// test262's `i1`: 1582966647747612578 ns, which is 1582966647 s plus 747612578 ns.
    def i1(): Instant = fromNanos(1_582_966_647_747_612_578i64)

    /// `Number.MAX_SAFE_INTEGER`.
    def maxSafeInteger(): Int64 = 9_007_199_254_740_991i64

    /// test262's `bigNumber`.
    def bigNumber(): Int64 = 9_007_199_254_740_990_976i64

    ///
    /// test262: `i1.add({ nanoseconds: MAX_SAFE_INTEGER })` is 1591973847002353569n.
    ///
    /// 1582966647747612578 + 9007199254740991 = 1591973847002353569, which is
    /// 1591973847 s plus 2353569 ns.
    ///
    @Test
    def add01_theLargestSafeNanosecondCount_carriesIntoTheSeconds(): Unit \ Assert =
        assertSomeInstant(expected = instant(1_591_973_847i64, 2_353_569),
                          tryAdd(i1(), Duration.nanoseconds(maxSafeInteger())),
                          "nanoseconds: Number.MAX_SAFE_INTEGER")

    ///
    /// test262: `i1.add({ nanoseconds: MIN_SAFE_INTEGER })` is 1573959448492871587n.
    ///
    /// 1582966647747612578 - 9007199254740991 = 1573959448492871587, which is
    /// 1573959448 s plus 492871587 ns.
    ///
    @Test
    def add02_theSmallestSafeNanosecondCount_borrowsFromTheSeconds(): Unit \ Assert =
        assertSomeInstant(expected = instant(1_573_959_448i64, 492_871_587),
                          tryAdd(i1(), Duration.nanoseconds(-maxSafeInteger())),
                          "nanoseconds: Number.MIN_SAFE_INTEGER")

    ///
    /// test262: `i1.add({ microseconds: MAX_SAFE_INTEGER })` is 10590165902488603578n.
    ///
    /// 9007199254740991 us is 9007199254740991000 ns, still inside an `Int64`, and the sum
    /// is 10590165902488603578 ns: 10590165902 s plus 488603578 ns. The total leaves the
    /// `Int64` nanosecond range but not the `Instant` range, whose seconds are an `Int64`
    /// of their own.
    ///
    @Test
    def add03_theLargestSafeMicrosecondCount_carriesPastTheNanosecondRange(): Unit \ Assert =
        assertSomeInstant(expected = instant(10_590_165_902i64, 488_603_578),
                          tryAdd(i1(), Duration.nanoseconds(9_007_199_254_740_991_000i64)),
                          "microseconds: Number.MAX_SAFE_INTEGER")

    ///
    /// test262: `i1.add({ microseconds: MIN_SAFE_INTEGER })` is -7424232606993378422n.
    ///
    /// 1582966647747612578 - 9007199254740991000 = -7424232606993378422, which is
    /// -7424232607 s plus 6621578 ns.
    ///
    @Test
    def add04_theSmallestSafeMicrosecondCount_borrowsPastTheEpoch(): Unit \ Assert =
        assertSomeInstant(expected = instant(-7_424_232_607i64, 6_621_578),
                          tryAdd(i1(), Duration.nanoseconds(-9_007_199_254_740_991_000i64)),
                          "microseconds: Number.MIN_SAFE_INTEGER")

    ///
    /// test262: `i1.add({ nanoseconds: bigNumber })` is 10590165902488603554n and
    /// `i1.add({ nanoseconds: -bigNumber })` is -7424232606993378398n.
    ///
    /// 1582966647747612578 + 9007199254740990976 = 10590165902488603554
    ///   -> 10590165902 s plus 488603554 ns.
    /// 1582966647747612578 - 9007199254740990976 = -7424232606993378398
    ///   -> -7424232607 s plus 6621602 ns.
    ///
    @Test
    def add05_bigNumberNanosecondsEitherWay_movesTheSecondsByOverNineBillion(): Unit \ Assert = {
        assertSomeInstant(expected = instant(10_590_165_902i64, 488_603_554),
                          tryAdd(i1(), Duration.nanoseconds(bigNumber())),
                          "nanoseconds: bigNumber");
        assertSomeInstant(expected = instant(-7_424_232_607i64, 6_621_602),
                          tryAdd(i1(), Duration.nanoseconds(-bigNumber())),
                          "nanoseconds: -bigNumber")
    }

    ///
    /// test262: `i2.add({ nanoseconds: bigNumber })` is 9007199254740990976n and
    /// `i2.add({ nanoseconds: -bigNumber })` is -9007199254740990976n, where `i2` is the epoch.
    ///
    /// 9007199254740990976 ns is 9007199254 s plus 740990976 ns; negated it is -9007199255 s
    /// plus 259009024 ns, since `nano` stays non-negative.
    ///
    @Test
    def add06_bigNumberNanosecondsFromTheEpoch_landsSymmetricallyEitherSide(): Unit \ Assert = {
        assertSomeInstant(expected = instant(9_007_199_254i64, 740_990_976),
                          tryAdd(epoch(), Duration.nanoseconds(bigNumber())),
                          "nanoseconds: bigNumber from the epoch");
        assertSomeInstant(expected = instant(-9_007_199_255i64, 259_009_024),
                          tryAdd(epoch(), Duration.nanoseconds(-bigNumber())),
                          "nanoseconds: -bigNumber from the epoch")
    }

}
