// Copyright (C) 2021 the V8 project authors. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.LocalDate; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/PlainDate/prototype/add/constrain-days.js`
/// (esid: sec-temporal.plaindate.prototype.add).
///
/// Every duration here is a whole number of months, so each case becomes `tryPlusMonths`.
///
/// `add` constrains the day to the end of a short month by default, and throws instead with
/// `{ overflow: "reject" }`. `java.time` only constrains, and so does `LocalDate`, so the
/// default half comes over and the `reject` half does not: the cases that throw have no
/// counterpart, and the ones that pass `reject` and succeed are the same additions as
/// without it.
///
mod Test262.BuiltIns.Temporal.PlainDate.Prototype.Add.ConstrainDays {

    use TemporalHelpers.{assertSomePlainDate, plainDate}
    use Time.LocalDate.{tryPlusMonths}

    /// test262: Common year, forwards.
    @Test
    def constrainDays01_commonYearForwards(): Unit \ Assert = {
        assertSomePlainDate(tryPlusMonths(plainDate(2019, 1, 31), 1i64),
                            2019, 2, 28, "common-year Feb constrains to 28");
        assertSomePlainDate(tryPlusMonths(plainDate(2019, 1, 31), 2i64),
                            2019, 3, 31, "common-year Mar does not reject 31");
        assertSomePlainDate(tryPlusMonths(plainDate(2019, 1, 31), 3i64),
                            2019, 4, 30, "common-year Apr constrains to 30");
        assertSomePlainDate(tryPlusMonths(plainDate(2019, 1, 31), 4i64),
                            2019, 5, 31, "common-year May does not reject 31");
        assertSomePlainDate(tryPlusMonths(plainDate(2019, 1, 31), 5i64),
                            2019, 6, 30, "common-year Jun constrains to 30");
        assertSomePlainDate(tryPlusMonths(plainDate(2019, 1, 31), 6i64),
                            2019, 7, 31, "common-year Jul does not reject 31");
        assertSomePlainDate(tryPlusMonths(plainDate(2019, 1, 31), 7i64),
                            2019, 8, 31, "common-year Aug does not reject 31");
        assertSomePlainDate(tryPlusMonths(plainDate(2019, 1, 31), 8i64),
                            2019, 9, 30, "common-year Sep constrains to 30");
        assertSomePlainDate(tryPlusMonths(plainDate(2019, 1, 31), 9i64),
                            2019, 10, 31, "common-year Oct does not reject 31");
        assertSomePlainDate(tryPlusMonths(plainDate(2019, 1, 31), 10i64),
                            2019, 11, 30, "common-year Nov constrains to 30");
        assertSomePlainDate(tryPlusMonths(plainDate(2019, 1, 31), 11i64),
                            2019, 12, 31, "common-year Dec does not reject 31")
    }

    /// test262: Leap year, forwards.
    @Test
    def constrainDays02_leapYearForwards(): Unit \ Assert = {
        assertSomePlainDate(tryPlusMonths(plainDate(2016, 1, 31), 1i64),
                            2016, 2, 29, "leap-year Feb constrains to 29");
        assertSomePlainDate(tryPlusMonths(plainDate(2016, 1, 31), 2i64),
                            2016, 3, 31, "leap-year Mar does not reject 31");
        assertSomePlainDate(tryPlusMonths(plainDate(2016, 1, 31), 3i64),
                            2016, 4, 30, "leap-year Apr constrains to 30");
        assertSomePlainDate(tryPlusMonths(plainDate(2016, 1, 31), 4i64),
                            2016, 5, 31, "leap-year May does not reject 31");
        assertSomePlainDate(tryPlusMonths(plainDate(2016, 1, 31), 5i64),
                            2016, 6, 30, "leap-year Jun constrains to 30");
        assertSomePlainDate(tryPlusMonths(plainDate(2016, 1, 31), 6i64),
                            2016, 7, 31, "leap-year Jul does not reject 31");
        assertSomePlainDate(tryPlusMonths(plainDate(2016, 1, 31), 7i64),
                            2016, 8, 31, "leap-year Aug does not reject 31");
        assertSomePlainDate(tryPlusMonths(plainDate(2016, 1, 31), 8i64),
                            2016, 9, 30, "leap-year Sep constrains to 30");
        assertSomePlainDate(tryPlusMonths(plainDate(2016, 1, 31), 9i64),
                            2016, 10, 31, "leap-year Oct does not reject 31");
        assertSomePlainDate(tryPlusMonths(plainDate(2016, 1, 31), 10i64),
                            2016, 11, 30, "leap-year Nov constrains to 30");
        assertSomePlainDate(tryPlusMonths(plainDate(2016, 1, 31), 11i64),
                            2016, 12, 31, "leap-year Dec does not reject 31")
    }

    /// test262: Common year, backwards.
    @Test
    def constrainDays03_commonYearBackwards(): Unit \ Assert = {
        assertSomePlainDate(tryPlusMonths(plainDate(2019, 12, 31), -1i64),
                            2019, 11, 30, "common-year Nov constrains to 30");
        assertSomePlainDate(tryPlusMonths(plainDate(2019, 12, 31), -2i64),
                            2019, 10, 31, "common-year Oct does not reject 31");
        assertSomePlainDate(tryPlusMonths(plainDate(2019, 12, 31), -3i64),
                            2019, 9, 30, "common-year Sep constrains to 30");
        assertSomePlainDate(tryPlusMonths(plainDate(2019, 12, 31), -4i64),
                            2019, 8, 31, "common-year Aug does not reject 31");
        assertSomePlainDate(tryPlusMonths(plainDate(2019, 12, 31), -5i64),
                            2019, 7, 31, "common-year Jul does not reject 31");
        assertSomePlainDate(tryPlusMonths(plainDate(2019, 12, 31), -6i64),
                            2019, 6, 30, "common-year Jun constrains to 30");
        assertSomePlainDate(tryPlusMonths(plainDate(2019, 12, 31), -7i64),
                            2019, 5, 31, "common-year May does not reject 31");
        assertSomePlainDate(tryPlusMonths(plainDate(2019, 12, 31), -8i64),
                            2019, 4, 30, "common-year Apr constrains to 30");
        assertSomePlainDate(tryPlusMonths(plainDate(2019, 12, 31), -9i64),
                            2019, 3, 31, "common-year Mar does not reject 31");
        assertSomePlainDate(tryPlusMonths(plainDate(2019, 12, 31), -10i64),
                            2019, 2, 28, "common-year Feb constrains to 28");
        assertSomePlainDate(tryPlusMonths(plainDate(2019, 12, 31), -11i64),
                            2019, 1, 31, "common-year Jan does not reject 31")
    }

    /// test262: Leap year, backwards.
    @Test
    def constrainDays04_leapYearBackwards(): Unit \ Assert = {
        assertSomePlainDate(tryPlusMonths(plainDate(2016, 12, 31), -1i64),
                            2016, 11, 30, "leap-year Nov constrains to 30");
        assertSomePlainDate(tryPlusMonths(plainDate(2016, 12, 31), -2i64),
                            2016, 10, 31, "leap-year Oct does not reject 31");
        assertSomePlainDate(tryPlusMonths(plainDate(2016, 12, 31), -3i64),
                            2016, 9, 30, "leap-year Sep constrains to 30");
        assertSomePlainDate(tryPlusMonths(plainDate(2016, 12, 31), -4i64),
                            2016, 8, 31, "leap-year Aug does not reject 31");
        assertSomePlainDate(tryPlusMonths(plainDate(2016, 12, 31), -5i64),
                            2016, 7, 31, "leap-year Jul does not reject 31");
        assertSomePlainDate(tryPlusMonths(plainDate(2016, 12, 31), -6i64),
                            2016, 6, 30, "leap-year Jun constrains to 30");
        assertSomePlainDate(tryPlusMonths(plainDate(2016, 12, 31), -7i64),
                            2016, 5, 31, "leap-year May does not reject 31");
        assertSomePlainDate(tryPlusMonths(plainDate(2016, 12, 31), -8i64),
                            2016, 4, 30, "leap-year Apr constrains to 30");
        assertSomePlainDate(tryPlusMonths(plainDate(2016, 12, 31), -9i64),
                            2016, 3, 31, "leap-year Mar does not reject 31");
        assertSomePlainDate(tryPlusMonths(plainDate(2016, 12, 31), -10i64),
                            2016, 2, 29, "leap-year Feb constrains to 29");
        assertSomePlainDate(tryPlusMonths(plainDate(2016, 12, 31), -11i64),
                            2016, 1, 31, "leap-year Jan does not reject 31")
    }

}
