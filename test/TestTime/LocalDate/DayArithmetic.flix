///
/// Tests for the day and week forms of `plus` and `minus` that test262 has no counterpart
/// for.
///
/// `Temporal.PlainDate.prototype.add` refuses a duration whose parts do not fit its own
/// limits before it gets as far as adding, so the ends of `Int64` never reach it. Here they
/// do: the amount is an `Int64`, and the cases below take it to either end. Negating
/// `Int64.minValue()` for `minus`, and multiplying it by seven for weeks, both overflow an
/// `Int64`, so each has a case.
///
/// The constructor is public, so a `LocalDate` can hold a day count outside the range. The
/// day and week forms add exactly all the same, and a sum that comes back into the range
/// is a date; the last cases pin that.
///
mod TestTime.LocalDate.DayArithmetic {

    use TemporalHelpers.{assertNoPlainDate, assertPlainDate, assertSomePlainDate, plainDate}
    use Time.LocalDate.{LocalDate, max, min, saturatingMinusDays, saturatingMinusWeeks,
                        saturatingPlusDays, saturatingPlusWeeks, tryMinusDays, tryMinusWeeks,
                        tryPlusDays, tryPlusWeeks}

    @Test
    def dayArithmetic01_theEndsOfInt64_areNone(): Unit \ Assert = {
        let d = plainDate(2000, 1, 1);
        assertNoPlainDate(tryPlusDays(d, Int64.maxValue()), "plus Int64.maxValue() days");
        assertNoPlainDate(tryPlusDays(d, Int64.minValue()), "plus Int64.minValue() days");
        assertNoPlainDate(tryMinusDays(d, Int64.maxValue()), "minus Int64.maxValue() days");
        assertNoPlainDate(tryMinusDays(d, Int64.minValue()), "minus Int64.minValue() days");
        assertNoPlainDate(tryPlusWeeks(d, Int64.maxValue()), "plus Int64.maxValue() weeks");
        assertNoPlainDate(tryPlusWeeks(d, Int64.minValue()), "plus Int64.minValue() weeks");
        assertNoPlainDate(tryMinusWeeks(d, Int64.maxValue()), "minus Int64.maxValue() weeks");
        assertNoPlainDate(tryMinusWeeks(d, Int64.minValue()), "minus Int64.minValue() weeks")
    }

    ///
    /// Each amount is saturated towards the end it points at. `Int64.minValue()` is
    /// negative, so subtracting it points at `max`: the negation has not wrapped round.
    ///
    @Test
    def dayArithmetic02_theEndsOfInt64_saturateTowardsTheEndTheyPointAt(): Unit \ Assert = {
        let d = plainDate(2000, 1, 1);
        assertPlainDate(saturatingPlusDays(d, Int64.maxValue()), 9_999, 12, 31, "plus Int64.maxValue() days");
        assertPlainDate(saturatingPlusDays(d, Int64.minValue()), -9_999, 1, 1, "plus Int64.minValue() days");
        assertPlainDate(saturatingMinusDays(d, Int64.maxValue()), -9_999, 1, 1, "minus Int64.maxValue() days");
        assertPlainDate(saturatingMinusDays(d, Int64.minValue()), 9_999, 12, 31, "minus Int64.minValue() days");
        assertPlainDate(saturatingPlusWeeks(d, Int64.maxValue()), 9_999, 12, 31, "plus Int64.maxValue() weeks");
        assertPlainDate(saturatingPlusWeeks(d, Int64.minValue()), -9_999, 1, 1, "plus Int64.minValue() weeks");
        assertPlainDate(saturatingMinusWeeks(d, Int64.maxValue()), -9_999, 1, 1, "minus Int64.maxValue() weeks");
        assertPlainDate(saturatingMinusWeeks(d, Int64.minValue()), 9_999, 12, 31, "minus Int64.minValue() weeks")
    }

    /// The whole range is 7304483 days, and crossing it from one end lands on the other.
    @Test
    def dayArithmetic03_theWidthOfTheRange_takesOneEndToTheOther(): Unit \ Assert = {
        assertSomePlainDate(tryPlusDays(min(), 7_304_483i64), 9_999, 12, 31, "min plus the width");
        assertSomePlainDate(tryMinusDays(max(), 7_304_483i64), -9_999, 1, 1, "max minus the width");
        assertNoPlainDate(tryPlusDays(min(), 7_304_484i64), "min plus one more");
        assertNoPlainDate(tryMinusDays(max(), 7_304_484i64), "max minus one more")
    }

    /// A week past either end is out, whichever day of the week the end falls on.
    @Test
    def dayArithmetic04_aWeekPastEitherEnd_isNone(): Unit \ Assert = {
        assertNoPlainDate(tryPlusWeeks(plainDate(9_999, 12, 25), 1i64), "9999-12-25 plus a week");
        assertSomePlainDate(tryPlusWeeks(plainDate(9_999, 12, 24), 1i64), 9_999, 12, 31, "9999-12-24 plus a week");
        assertNoPlainDate(tryMinusWeeks(plainDate(-9_999, 1, 7), 1i64), "-9999-01-07 minus a week");
        assertSomePlainDate(tryMinusWeeks(plainDate(-9_999, 1, 8), 1i64), -9_999, 1, 1, "-9999-01-08 minus a week")
    }

    ///
    /// A day count built directly at an end of `Int64` is far outside the range, but adding
    /// the other end of `Int64` to it lands on day -1, 1969-12-31. The sum is exact, not
    /// wrapped: the answer is that date, not `None`.
    ///
    @Test
    def dayArithmetic05_fromOutsideTheRange_backIntoIt_isThatDate(): Unit \ Assert = {
        assertSomePlainDate(tryPlusDays(LocalDate(Int64.maxValue()), Int64.minValue()), 1969, 12, 31,
                            "Int64.maxValue() plus Int64.minValue()");
        assertSomePlainDate(tryMinusDays(LocalDate(Int64.minValue()), Int64.minValue()), 1970, 1, 1,
                            "Int64.minValue() minus Int64.minValue()")
    }

    /// A sum that wraps round an `Int64` would come back into the range; it must not.
    @Test
    def dayArithmetic06_fromOutsideTheRange_furtherOut_isNone(): Unit \ Assert = {
        assertNoPlainDate(tryPlusDays(LocalDate(Int64.maxValue()), 1i64), "Int64.maxValue() plus one");
        assertNoPlainDate(tryMinusDays(LocalDate(Int64.minValue()), 1i64), "Int64.minValue() minus one");
        assertPlainDate(saturatingPlusDays(LocalDate(Int64.maxValue()), 1i64), 9_999, 12, 31, "saturating plus");
        assertPlainDate(saturatingMinusDays(LocalDate(Int64.minValue()), 1i64), -9_999, 1, 1, "saturating minus")
    }

}
