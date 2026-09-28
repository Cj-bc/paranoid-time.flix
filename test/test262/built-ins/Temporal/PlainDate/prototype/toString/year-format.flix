// Copyright (C) 2022 Igalia, S.L.. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.LocalDate; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/PlainDate/prototype/toString/year-format.js`
/// (esid: sec-temporal.plaindate.prototype.tostring).
///
/// `toString()` becomes `ToString[LocalDate]`, and the two differ outside the years 0 to
/// 9999. `Temporal` writes such a year with a sign and six digits, the ISO-8601 expanded
/// form; `java.time`, which this library follows, writes the sign and at least four
/// digits. So -1 is `-0001` here where test262 expects `-000001`.
///
/// The years from 0 to 9999 come over unchanged. The negative ones in the range are
/// restated in the four-digit form. The five- and six-digit years, -100000, -10000, 10000
/// and 100000, are outside the range and are not ported.
///
mod Test262.BuiltIns.Temporal.PlainDate.Prototype.ToString.YearFormat {

    use TemporalHelpers.plainDate

    def check(year: Int32, month: Int32, day: Int32, expected: String, msg: String): Unit \ Assert =
        Assert.assertEqWithMsg(expected = expected, ToString.toString(plainDate(year, month, day)), msg)

    ///
    /// test262 expects `-009999-06-07`, `-001000-08-09`, `-000999-10-09` and `-000001-08-07`.
    ///
    @Test
    def yearFormat01_negativeYears_areFourDigitsWithASign(): Unit \ Assert = {
        check(-9_999, 6, 7, "-9999-06-07", "largest 4-digit negative year");
        check(-1_000, 8, 9, "-1000-08-09", "smallest 4-digit negative year");
        check(-999, 10, 9, "-0999-10-09", "largest 3-digit negative year");
        check(-1, 8, 7, "-0001-08-07", "year -1")
    }

    @Test
    def yearFormat02_yearsFromZeroTo9999_areFourDigits(): Unit \ Assert = {
        check(0, 6, 5, "0000-06-05", "year 0 formatted as 4-digit");
        check(1, 4, 3, "0001-04-03", "year 1 formatted as 4-digit");
        check(999, 2, 10, "0999-02-10", "largest 3-digit positive year formatted as 4-digit");
        check(1_000, 1, 23, "1000-01-23", "smallest 4-digit positive year formatted as 4-digit");
        check(9_999, 4, 5, "9999-04-05", "largest 4-digit positive year formatted as 4-digit")
    }

}
