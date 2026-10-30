///
/// The field accessors away from the dates test262 picks, which are all in the years 1970
/// to 2026: before the epoch, around year 0, and at the ends of the range.
///
/// Every date here is built by the harness's `plainDate`, whose day count is worked out
/// independently of `Time.LocalDate`, and `assertPlainDate` reads the year, month and day
/// back through the accessors.
///
mod TestTime.LocalDate.Fields {

    use TemporalHelpers.{assertPlainDate, plainDate}
    use Time.DayOfWeek.DayOfWeek
    use Time.LocalDate.{getDayOfWeek, getDayOfYear, isLeapYear, lengthOfMonth, lengthOfYear, max, min}

    ///
    /// The accessors undo `plainDate` on dates the other cases do not reach: the day before
    /// the epoch, the last day of year -1 and the first of year 0, and the leap days of
    /// negative years.
    ///
    @Test
    def fields01_awayFromThePresent_readBackTheFieldsTheyWereBuiltFrom(): Unit \ Assert =
        List.forEach(match (y, m, d) -> assertPlainDate(plainDate(y, m, d), y, m, d, "${y}-${m}-${d}"),
                     List#{(1969, 12, 31), (0, 1, 1), (-1, 12, 31), (0, 2, 29), (-4, 2, 29),
                           (-400, 2, 29), (-9_999, 12, 31), (9_999, 1, 1), (1600, 3, 1), (1, 1, 1)})

    ///
    /// Year 0 is a leap year, as is every multiple of 400 on either side of it. Every other
    /// multiple of 100 is not, on either side.
    ///
    @Test
    def fields02_leapYears_onEitherSideOfYearZero(): Unit \ Assert =
        List.forEach(match (y, expected) ->
                       Assert.assertEqWithMsg(expected = (expected, if (expected) 366 else 365),
                                              (isLeapYear(plainDate(y, 1, 1)), lengthOfYear(plainDate(y, 1, 1))),
                                              "year ${y}"),
                     List#{(0, true), (-4, true), (-100, false), (-400, true), (-1, false),
                           (1900, false), (2000, true), (-9_996, true), (9_996, true)})

    @Test
    def fields03_lengthOfMonth_forFebruaryOfNegativeYears(): Unit \ Assert = {
        Assert.assertEqWithMsg(expected = 29, lengthOfMonth(plainDate(-4, 2, 1)), "-4");
        Assert.assertEqWithMsg(expected = 28, lengthOfMonth(plainDate(-100, 2, 1)), "-100")
    }

    @Test
    def fields04_getDayOfYear_atTheEnds(): Unit \ Assert =
        Assert.assertEq(expected = (1, 365), (getDayOfYear(min()), getDayOfYear(max())))

    ///
    /// The epoch was a Thursday. 0001-01-01 was a Monday, and a 400-year cycle is a whole
    /// number of weeks (146097 = 7 * 20871), so -9999-01-01, 25 cycles before it, was too.
    ///
    @Test
    def fields05_getDayOfWeek_onDaysKnownFromTheCalendar(): Unit \ Assert = {
        Assert.assertEqWithMsg(expected = DayOfWeek.Thursday, getDayOfWeek(plainDate(1970, 1, 1)), "the epoch");
        Assert.assertEqWithMsg(expected = DayOfWeek.Wednesday, getDayOfWeek(plainDate(1969, 12, 31)), "the day before");
        Assert.assertEqWithMsg(expected = DayOfWeek.Monday, getDayOfWeek(plainDate(1, 1, 1)), "0001-01-01");
        Assert.assertEqWithMsg(expected = DayOfWeek.Monday, getDayOfWeek(min()), "min");
        Assert.assertEqWithMsg(expected = DayOfWeek.Friday, getDayOfWeek(max()), "max")
    }

}
