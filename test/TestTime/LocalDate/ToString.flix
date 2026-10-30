///
/// Tests for `ToString[LocalDate]` that test262 has no counterpart for.
///
/// `toString/year-format.js` is ported under `test/test262` with its years restated in the
/// `java.time` form. What is left is the ends of the range, and the `+` that `java.time`
/// writes before a year above 9999, which only a day count built directly outside the range
/// can reach.
///
mod TestTime.LocalDate.ToString {

    use TemporalHelpers.plainDate
    use Time.LocalDate.{LocalDate, max, min, toEpochDay}

    @Test
    def toString01_theEnds(): Unit \ Assert =
        Assert.assertEq(expected = ("-9999-01-01", "9999-12-31"), (ToString.toString(min()), ToString.toString(max())))

    @Test
    def toString02_aYearAbove9999_hasAPlusSign(): Unit \ Assert =
        Assert.assertEq(expected = "+10000-01-01", ToString.toString(plainDate(10_000, 1, 1)))

    /// The harness's `plainDate` only reaches back to -9999, so the day before it is built from `min`.
    @Test
    def toString03_aYearBelowMinus9999_hasFiveDigits(): Unit \ Assert =
        Assert.assertEq(expected = "-10000-12-31", ToString.toString(LocalDate(toEpochDay(min()) - 1i64)))

}
