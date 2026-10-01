// Copyright (C) 2022 Igalia, S.L. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.LocalDate; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/PlainDate/argument-invalid.js`
/// (esid: sec-temporal.plaindate).
///
/// The constructor becomes `tryOf`, and a `RangeError` becomes `None`. The cases come
/// over unchanged.
///
mod Test262.BuiltIns.Temporal.PlainDate.ArgumentInvalid {

    use TemporalHelpers.assertNoPlainDate
    use Time.LocalDate.tryOf

    @Test
    def argumentInvalid01_noSuchMonthOrDay_isNotADate(): Unit \ Assert =
        List.forEach(match (year, month, day) ->
                       assertNoPlainDate(tryOf(year, month, day), "year=${year}, month=${month}, day=${day}"),
                     List#{(2020, 0, 24), (2020, 13, 24), (2020, -3, 24), (2020, 12, 32),
                           (2020, 2, 30), (2019, 2, 29), (2019, 2, 0), (2019, 2, -20)})

}
