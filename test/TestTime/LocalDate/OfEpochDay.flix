///
/// Tests for `tryOfEpochDay` and `saturatingOfEpochDay`.
///
/// `Temporal.PlainDate` has no day-count constructor, so there is nothing to port. The
/// cases are the epoch, the two ends of the range from both sides, and the two ends of
/// `Int64`, which overshoot the range by about twelve orders of magnitude.
///
mod TestTime.LocalDate.OfEpochDay {

    use TemporalHelpers.{assertNoPlainDate, assertPlainDate, assertSomePlainDate}
    use Time.LocalDate.{max, min, saturatingOfEpochDay, toEpochDay, tryOfEpochDay}

    @Test
    def tryOfEpochDay01_zero_isTheEpoch(): Unit \ Assert =
        assertSomePlainDate(tryOfEpochDay(0i64), 1970, 1, 1, "day 0")

    @Test
    def tryOfEpochDay02_minusOne_isTheDayBeforeTheEpoch(): Unit \ Assert =
        assertSomePlainDate(tryOfEpochDay(-1i64), 1969, 12, 31, "day -1")

    @Test
    def tryOfEpochDay03_eitherEnd_isADate(): Unit \ Assert = {
        assertSomePlainDate(tryOfEpochDay(toEpochDay(min())), -9_999, 1, 1, "min");
        assertSomePlainDate(tryOfEpochDay(toEpochDay(max())), 9_999, 12, 31, "max")
    }

    @Test
    def tryOfEpochDay04_oneDayPastEitherEnd_isNone(): Unit \ Assert = {
        assertNoPlainDate(tryOfEpochDay(toEpochDay(min()) - 1i64), "one day before min");
        assertNoPlainDate(tryOfEpochDay(toEpochDay(max()) + 1i64), "one day after max")
    }

    @Test
    def tryOfEpochDay05_theEndsOfInt64_areNone(): Unit \ Assert = {
        assertNoPlainDate(tryOfEpochDay(Int64.minValue()), "Int64.minValue()");
        assertNoPlainDate(tryOfEpochDay(Int64.maxValue()), "Int64.maxValue()")
    }

    @Test
    def saturatingOfEpochDay01_withinRange_isThatDay(): Unit \ Assert = {
        assertPlainDate(saturatingOfEpochDay(0i64), 1970, 1, 1, "day 0");
        assertPlainDate(saturatingOfEpochDay(toEpochDay(min())), -9_999, 1, 1, "min");
        assertPlainDate(saturatingOfEpochDay(toEpochDay(max())), 9_999, 12, 31, "max")
    }

    @Test
    def saturatingOfEpochDay02_pastEitherEnd_isThatEnd(): Unit \ Assert = {
        assertPlainDate(saturatingOfEpochDay(toEpochDay(min()) - 1i64), -9_999, 1, 1, "one day before min");
        assertPlainDate(saturatingOfEpochDay(toEpochDay(max()) + 1i64), 9_999, 12, 31, "one day after max");
        assertPlainDate(saturatingOfEpochDay(Int64.minValue()), -9_999, 1, 1, "Int64.minValue()");
        assertPlainDate(saturatingOfEpochDay(Int64.maxValue()), 9_999, 12, 31, "Int64.maxValue()")
    }

}
