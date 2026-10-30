///
/// Tests for the month and year forms of `plus` and `minus` that test262 has no
/// counterpart for.
///
/// As with the day forms, the amount is an `Int64` and the cases take it to either end,
/// where negating it for `minus`, or multiplying years into months, overflows an `Int64`.
///
/// Unlike the day forms, a month or a year is counted from the date's fields, and a day
/// count built directly outside the range has none. Such a value is reported as lying
/// past the end it is outside of, whatever the amount.
///
mod TestTime.LocalDate.MonthArithmetic {

    use TemporalHelpers.{assertNoPlainDate, assertPlainDate, assertSomePlainDate, plainDate}
    use Time.LocalDate.{LocalDate, max, min, saturatingMinusMonths, saturatingMinusYears,
                        saturatingPlusMonths, saturatingPlusYears, tryMinusMonths, tryMinusYears,
                        tryPlusMonths, tryPlusYears}

    @Test
    def monthArithmetic01_theEndsOfInt64_areNone(): Unit \ Assert = {
        let d = plainDate(2000, 1, 1);
        assertNoPlainDate(tryPlusMonths(d, Int64.maxValue()), "plus Int64.maxValue() months");
        assertNoPlainDate(tryPlusMonths(d, Int64.minValue()), "plus Int64.minValue() months");
        assertNoPlainDate(tryMinusMonths(d, Int64.maxValue()), "minus Int64.maxValue() months");
        assertNoPlainDate(tryMinusMonths(d, Int64.minValue()), "minus Int64.minValue() months");
        assertNoPlainDate(tryPlusYears(d, Int64.maxValue()), "plus Int64.maxValue() years");
        assertNoPlainDate(tryPlusYears(d, Int64.minValue()), "plus Int64.minValue() years");
        assertNoPlainDate(tryMinusYears(d, Int64.maxValue()), "minus Int64.maxValue() years");
        assertNoPlainDate(tryMinusYears(d, Int64.minValue()), "minus Int64.minValue() years")
    }

    @Test
    def monthArithmetic02_theEndsOfInt64_saturateTowardsTheEndTheyPointAt(): Unit \ Assert = {
        let d = plainDate(2000, 1, 1);
        assertPlainDate(saturatingPlusMonths(d, Int64.maxValue()), 9_999, 12, 31, "plus Int64.maxValue() months");
        assertPlainDate(saturatingPlusMonths(d, Int64.minValue()), -9_999, 1, 1, "plus Int64.minValue() months");
        assertPlainDate(saturatingMinusMonths(d, Int64.maxValue()), -9_999, 1, 1, "minus Int64.maxValue() months");
        assertPlainDate(saturatingMinusMonths(d, Int64.minValue()), 9_999, 12, 31, "minus Int64.minValue() months");
        assertPlainDate(saturatingPlusYears(d, Int64.maxValue()), 9_999, 12, 31, "plus Int64.maxValue() years");
        assertPlainDate(saturatingPlusYears(d, Int64.minValue()), -9_999, 1, 1, "plus Int64.minValue() years");
        assertPlainDate(saturatingMinusYears(d, Int64.maxValue()), -9_999, 1, 1, "minus Int64.maxValue() years");
        assertPlainDate(saturatingMinusYears(d, Int64.minValue()), 9_999, 12, 31, "minus Int64.minValue() years")
    }

    ///
    /// The first month of the range and the last, -9999-01 and 9999-12, are 239987 months
    /// apart: 19999 years of 12 months, less one. Exactly across is a date; one month more
    /// is not.
    ///
    @Test
    def monthArithmetic03_theWidthOfTheRangeInMonths_takesOneEndToTheOther(): Unit \ Assert = {
        assertSomePlainDate(tryPlusMonths(min(), 239_987i64), 9_999, 12, 1, "min plus the width");
        assertSomePlainDate(tryMinusMonths(max(), 239_987i64), -9_999, 1, 31, "max minus the width");
        assertNoPlainDate(tryPlusMonths(min(), 239_988i64), "min plus one more");
        assertNoPlainDate(tryMinusMonths(max(), 239_988i64), "max minus one more")
    }

    @Test
    def monthArithmetic04_theWidthOfTheRangeInYears_takesOneEndToTheOther(): Unit \ Assert = {
        assertSomePlainDate(tryPlusYears(min(), 19_998i64), 9_999, 1, 1, "min plus 19998 years");
        assertSomePlainDate(tryMinusYears(max(), 19_998i64), -9_999, 12, 31, "max minus 19998 years");
        assertNoPlainDate(tryPlusYears(min(), 19_999i64), "min plus 19999 years");
        assertNoPlainDate(tryMinusYears(max(), 19_999i64), "max minus 19999 years")
    }

    /// A month past either end is out even when the day has to be pulled back first.
    @Test
    def monthArithmetic05_aMonthPastEitherEnd_isNone(): Unit \ Assert = {
        assertNoPlainDate(tryPlusMonths(plainDate(9_999, 12, 1), 1i64), "9999-12-01 plus a month");
        assertSomePlainDate(tryPlusMonths(plainDate(9_999, 10, 31), 1i64), 9_999, 11, 30, "9999-10-31 plus a month");
        assertNoPlainDate(tryMinusMonths(plainDate(-9_999, 1, 31), 1i64), "-9999-01-31 minus a month")
    }

    @Test
    def monthArithmetic06_fromOutsideTheRange_isThatEnd(): Unit \ Assert = {
        assertNoPlainDate(tryMinusMonths(LocalDate(Int64.maxValue()), 1i64), "far after max, minus a month");
        assertNoPlainDate(tryPlusYears(LocalDate(Int64.minValue()), 1i64), "far before min, plus a year");
        assertPlainDate(saturatingMinusMonths(LocalDate(Int64.maxValue()), 1i64), 9_999, 12, 31, "saturating, after max");
        assertPlainDate(saturatingPlusYears(LocalDate(Int64.minValue()), 1i64), -9_999, 1, 1, "saturating, before min")
    }

    /// Years move a leap day to February 28 of a common year, on either side of year 0.
    @Test
    def monthArithmetic07_aLeapDayPlusAYear_isFebruaryTheTwentyEighth(): Unit \ Assert = {
        assertSomePlainDate(tryPlusYears(plainDate(0, 2, 29), 1i64), 1, 2, 28, "0000-02-29 plus a year");
        assertSomePlainDate(tryMinusYears(plainDate(0, 2, 29), 1i64), -1, 2, 28, "0000-02-29 minus a year");
        assertSomePlainDate(tryMinusYears(plainDate(0, 2, 29), 400i64), -400, 2, 29, "0000-02-29 minus 400 years")
    }

}
