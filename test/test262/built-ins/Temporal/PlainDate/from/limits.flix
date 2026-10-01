// Copyright (C) 2021 Igalia, S.L. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.LocalDate; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/PlainDate/from/limits.js`
/// (esid: sec-temporal.plaindate.from).
///
/// `Temporal.PlainDate.from` with a property bag becomes `tryOf`. The string forms are not
/// ported, since `LocalDate` has no parser, and neither is the `overflow` option: `tryOf`
/// only ever rejects, which is what test262 expects of both settings here.
///
/// The limits are restated from `Temporal`'s -271821-04-19 and 275760-09-13 to this
/// library's -9999-01-01 and 9999-12-31, as in `../limits.flix`.
///
mod Test262.BuiltIns.Temporal.PlainDate.From.Limits {

    use TemporalHelpers.{assertNoPlainDate, assertSomePlainDate}
    use Time.LocalDate.tryOf

    /// test262: `tooEarly` and `tooLate` throw.
    @Test
    def limits01_theDayBeyondEitherEnd_isNotADate(): Unit \ Assert = {
        assertNoPlainDate(tryOf(-10_000, 12, 31), "tooEarly");
        assertNoPlainDate(tryOf(10_000, 1, 1), "tooLate")
    }

    /// test262: "min object" and "max object".
    @Test
    def limits02_eitherEnd_isADate(): Unit \ Assert = {
        assertSomePlainDate(tryOf(-9_999, 1, 1), -9_999, 1, 1, "min object");
        assertSomePlainDate(tryOf(9_999, 12, 31), 9_999, 12, 31, "max object")
    }

}
