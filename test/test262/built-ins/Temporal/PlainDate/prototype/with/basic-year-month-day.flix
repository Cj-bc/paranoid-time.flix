// Copyright 2025 Igalia S.L.. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.LocalDate; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/PlainDate/prototype/with/basic-year-month-day.js`
/// (esid: sec-temporal.plaindate.prototype.with).
///
/// `with` takes a bag of fields; `java.time` has one `with*` per field, and so does
/// `LocalDate`, answering an `Option`. `with({ day })` becomes `tryWithDayOfMonth`,
/// `with({ month })` `tryWithMonth`, and `with({ year })` `tryWithYear`. The three starting
/// dates, built from property bags in test262, become the harness's `plainDate`.
///
mod Test262.BuiltIns.Temporal.PlainDate.Prototype.With.BasicYearMonthDay {

    use TemporalHelpers.{assertSomePlainDate, plainDate}
    use Time.LocalDate.{tryWithDayOfMonth, tryWithMonth, tryWithYear}

    def check(name: String, year: Int32, month: Int32, day: Int32): Unit \ Assert = {
        let inCal = plainDate(year, month, day);

        let afterWithDay = tryWithDayOfMonth(inCal, 1);
        assertSomePlainDate(afterWithDay, year, month, 1, "${name} after setting day to 1");
        let afterWithMonth = afterWithDay |> Option.flatMap(d -> tryWithMonth(d, 1));
        assertSomePlainDate(afterWithMonth, year, 1, 1, "${name} after setting month to 1");
        let afterWithYear = afterWithMonth |> Option.flatMap(d -> tryWithYear(d, 2220));
        assertSomePlainDate(afterWithYear, 2220, 1, 1, "${name} after setting year to 2220");

        let afterWithYear2 = tryWithYear(inCal, 2019);
        assertSomePlainDate(afterWithYear2, 2019, month, day, "${name} after setting year to 2019");
        let afterWithMonth2 = afterWithYear2 |> Option.flatMap(d -> tryWithMonth(d, 5));
        assertSomePlainDate(afterWithMonth2, 2019, 5, day, "${name} after setting month to 5");
        let afterWithDay2 = afterWithMonth2 |> Option.flatMap(d -> tryWithDayOfMonth(d, 17));
        assertSomePlainDate(afterWithDay2, 2019, 5, 17, "${name} after setting day to 17")
    }

    @Test
    def basicYearMonthDay01_year2000(): Unit \ Assert = check("year2000", 2000, 1, 1)

    @Test
    def basicYearMonthDay02_year1976(): Unit \ Assert = check("year1976", 1976, 11, 18)

    @Test
    def basicYearMonthDay03_year1(): Unit \ Assert = check("year1", 1, 1, 1)

}
