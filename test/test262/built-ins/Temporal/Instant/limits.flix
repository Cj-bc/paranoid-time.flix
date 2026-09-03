///
/// Ported from test262 `test/built-ins/Temporal/Instant/limits.js`
/// (esid: sec-temporal.instant, "Min/max range").
///
/// test262 pins the range at +/-8.64e21 nanoseconds and checks that one nanosecond
/// beyond either end throws a `RangeError`. The range here is a different one — the
/// whole `Int64` second line, with `nano` at 0 at the bottom and at its ceiling at the
/// top — and there is no validating constructor to make throw, so the ends are pinned
/// through the arithmetic instead: stepping one nanosecond past either end fails.
///
/// Not portable: the two `Temporal.Instant.from` string comparisons, which name the
/// limits as calendar dates.
///
mod Test262.BuiltIns.Temporal.Instant.Limits {

    use TemporalHelpers.assertNoInstant
    use TemporalHelpers.assertSaturated
    use TemporalHelpers.instant
    use TemporalHelpers.maxInstant
    use TemporalHelpers.minInstant
    use Time.Duration
    use Time.Instant.saturatingAdd
    use Time.Instant.saturatingSub
    use Time.Instant.tryAdd
    use Time.Instant.trySub

    /// test262: `new Temporal.Instant(limit + 1n)` throws.
    @Test
    def limits01_oneNanosecondAboveTheLatestInstant_isNotRepresentable(): Unit \ Assert =
        assertNoInstant(tryAdd(maxInstant(), Duration.nanoseconds(1i64)),
                        "one nanosecond above the latest instant")

    /// test262: `new Temporal.Instant(-limit - 1n)` throws.
    @Test
    def limits02_oneNanosecondBelowTheEarliestInstant_isNotRepresentable(): Unit \ Assert =
        assertNoInstant(trySub(minInstant(), Duration.nanoseconds(1i64)),
                        "one nanosecond below the earliest instant")

    ///
    /// The `saturating` half of the two cases above, which test262 has no counterpart for:
    /// `Temporal` only offers the throwing form.
    ///
    @Test
    def limits03_pastEitherEnd_saturatesToThatEnd(): Unit \ Assert = {
        assertSaturated(expected = maxInstant(), saturatingAdd(maxInstant(), Duration.nanoseconds(1i64)),
                        "one nanosecond above the latest instant");
        assertSaturated(expected = minInstant(), saturatingSub(minInstant(), Duration.nanoseconds(1i64)),
                        "one nanosecond below the earliest instant")
    }

    /// test262: `new Temporal.Instant(limit)` and `new Temporal.Instant(-limit)` are fine.
    @Test
    def limits04_theEndsThemselves_areRepresentable(): Unit \ Assert = {
        TemporalHelpers.assertSomeInstant(expected = maxInstant(), tryAdd(maxInstant(), Duration.zero()),
                                          "the latest instant");
        TemporalHelpers.assertSomeInstant(expected = minInstant(), tryAdd(minInstant(), Duration.zero()),
                                          "the earliest instant")
    }

    ///
    /// The ends bound `Order` as well, so no instant sorts outside them.
    ///
    /// No test262 counterpart: `Temporal.Instant.compare` cannot be handed a value
    /// outside the range, because constructing one already throws.
    ///
    @Test
    def limits05_everyInstant_sortsBetweenTheTwoEnds(): Unit \ Assert = {
        Assert.assertTrue(minInstant() < instant(0i64, 0));
        Assert.assertTrue(instant(0i64, 0) < maxInstant());
        Assert.assertTrue(minInstant() < instant(Int64.minValue(), 1));
        Assert.assertTrue(instant(Int64.maxValue(), 999_999_998) < maxInstant())
    }

}
