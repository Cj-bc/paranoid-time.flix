///
/// Tests for `tryOfYearDay`.
///
/// `Temporal.PlainDate` has no day-of-year constructor, so there is nothing to port.
///
mod TestTime.LocalDate.TryOfYearDay {

    use TemporalHelpers.{assertNoPlainDate, assertSomePlainDate}
    use Time.LocalDate.tryOfYearDay

    @Test
    def tryOfYearDay01_theFirstAndLastDays_ofACommonYear(): Unit \ Assert = {
        assertSomePlainDate(tryOfYearDay(2021, 1), 2021, 1, 1, "day 1");
        assertSomePlainDate(tryOfYearDay(2021, 365), 2021, 12, 31, "day 365");
        assertNoPlainDate(tryOfYearDay(2021, 366), "day 366 of a common year")
    }

    @Test
    def tryOfYearDay02_theLeapDayAndTheLastDay_ofALeapYear(): Unit \ Assert = {
        assertSomePlainDate(tryOfYearDay(2020, 60), 2020, 2, 29, "day 60");
        assertSomePlainDate(tryOfYearDay(2020, 366), 2020, 12, 31, "day 366");
        assertNoPlainDate(tryOfYearDay(2020, 367), "day 367")
    }

    @Test
    def tryOfYearDay03_dayZeroOrBelow_isNone(): Unit \ Assert = {
        assertNoPlainDate(tryOfYearDay(2020, 0), "day 0");
        assertNoPlainDate(tryOfYearDay(2020, -1), "day -1")
    }

    @Test
    def tryOfYearDay04_theYearsAtAndPastEitherEnd(): Unit \ Assert = {
        assertSomePlainDate(tryOfYearDay(-9_999, 1), -9_999, 1, 1, "the first day of -9999");
        assertSomePlainDate(tryOfYearDay(9_999, 365), 9_999, 12, 31, "the last day of 9999");
        assertNoPlainDate(tryOfYearDay(-10_000, 366), "the last day of -10000");
        assertNoPlainDate(tryOfYearDay(10_000, 1), "the first day of 10000")
    }

}
