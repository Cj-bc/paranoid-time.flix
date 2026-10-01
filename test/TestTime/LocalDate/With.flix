///
/// Tests for the `with*` functions that test262 has no counterpart for.
///
/// `tryWithDayOfYear` has no `Temporal` counterpart at all: `with` takes no day of the
/// year. The other three are ported from `with/` under `test/test262`; what is left here is
/// their behaviour on a day count built directly outside the range, which has no fields to
/// replace.
///
mod TestTime.LocalDate.With {

    use TemporalHelpers.{assertNoPlainDate, assertSomePlainDate, plainDate}
    use Time.LocalDate.{LocalDate, max, tryWithDayOfMonth, tryWithDayOfYear, tryWithMonth, tryWithYear}

    @Test
    def tryWithDayOfYear01_withinTheYear_isThatDay(): Unit \ Assert = {
        assertSomePlainDate(tryWithDayOfYear(plainDate(2020, 7, 15), 1), 2020, 1, 1, "day 1");
        assertSomePlainDate(tryWithDayOfYear(plainDate(2020, 7, 15), 366), 2020, 12, 31, "day 366 of a leap year");
        assertSomePlainDate(tryWithDayOfYear(plainDate(2021, 7, 15), 60), 2021, 3, 1, "day 60 of a common year")
    }

    @Test
    def tryWithDayOfYear02_outsideTheYear_isNone(): Unit \ Assert = {
        assertNoPlainDate(tryWithDayOfYear(plainDate(2021, 7, 15), 366), "day 366 of a common year");
        assertNoPlainDate(tryWithDayOfYear(plainDate(2020, 7, 15), 0), "day 0")
    }

    @Test
    def with01_atTheEnds_staysInRange(): Unit \ Assert = {
        assertSomePlainDate(tryWithYear(max(), -9_999), -9_999, 12, 31, "max with year -9999");
        assertSomePlainDate(tryWithMonth(max(), 2), 9_999, 2, 28, "max with February");
        assertSomePlainDate(tryWithDayOfMonth(max(), 1), 9_999, 12, 1, "max with day 1")
    }

    @Test
    def with02_fromOutsideTheRange_isNone(): Unit \ Assert = {
        let far = LocalDate(Int64.maxValue());
        assertNoPlainDate(tryWithYear(far, 2000), "tryWithYear");
        assertNoPlainDate(tryWithMonth(far, 1), "tryWithMonth");
        assertNoPlainDate(tryWithDayOfMonth(far, 1), "tryWithDayOfMonth");
        assertNoPlainDate(tryWithDayOfYear(far, 1), "tryWithDayOfYear")
    }

}
