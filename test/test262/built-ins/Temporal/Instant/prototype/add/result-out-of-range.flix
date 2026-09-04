// Copyright (C) 2021 Igalia, S.L. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.Instant; the module doc comment says what changed.
///
/// Ported from test262
/// `test/built-ins/Temporal/Instant/prototype/add/result-out-of-range.js`
/// (esid: sec-temporal.instant.prototype.add).
///
/// test262 walks the six sub-day units and expects a `RangeError` for each of them, once
/// upwards from the latest instant and once downwards from the earliest one. Each of those
/// becomes two checks here: `tryAdd` answers `None`, and `saturatingAdd` answers the end it
/// ran into.
///
/// One unit of any size is enough to tip either end over, because neither end has room in
/// `nano` — it is 0 at the bottom and 999999999 at the top.
///
mod Test262.BuiltIns.Temporal.Instant.Prototype.Add.ResultOutOfRange {

    use TemporalHelpers.assertNoInstant
    use TemporalHelpers.assertSaturated
    use TemporalHelpers.maxInstant
    use TemporalHelpers.minInstant
    use Time.Duration
    use Time.Instant.saturatingAdd
    use Time.Instant.tryAdd

    /// test262's `fields`, as one unit of each.
    def oneOfEachUnit(): List[(String, Duration)] =
        ("hours", Duration.hours(1)) ::
        ("minutes", Duration.minutes(1)) ::
        ("seconds", Duration.seconds(1)) ::
        ("milliseconds", Duration.milliseconds(1)) ::
        ("microseconds", Duration.microseconds(1)) ::
        ("nanoseconds", Duration.nanoseconds(1i64)) ::
        Nil

    /// The same six units negated.
    def minusOneOfEachUnit(): List[(String, Duration)] =
        ("hours", Duration.hours(-1)) ::
        ("minutes", Duration.minutes(-1)) ::
        ("seconds", Duration.seconds(-1)) ::
        ("milliseconds", Duration.milliseconds(-1)) ::
        ("microseconds", Duration.microseconds(-1)) ::
        ("nanoseconds", Duration.nanoseconds(-1i64)) ::
        Nil

    /// test262: `latest.add({ [field]: 1 })` throws for each field.
    @Test
    def add01_oneOfAnyUnitAtTheLatestInstant_isOutOfRange(): Unit \ Assert =
        List.forEach(unit -> {
            let (name, d) = unit;
            assertNoInstant(tryAdd(maxInstant(), d), "adding ${name} with result out of range (positive)")
        }, oneOfEachUnit())

    /// test262: `earliest.add({ [field]: -1 })` throws for each field.
    @Test
    def add02_minusOneOfAnyUnitAtTheEarliestInstant_isOutOfRange(): Unit \ Assert =
        List.forEach(unit -> {
            let (name, d) = unit;
            assertNoInstant(tryAdd(minInstant(), d), "adding ${name} with result out of range (negative)")
        }, minusOneOfEachUnit())

    ///
    /// The `saturating` half of the two cases above, which test262 has no counterpart for.
    ///
    @Test
    def add03_pastEitherEnd_saturatesToThatEnd(): Unit \ Assert = {
        List.forEach(unit -> {
            let (name, d) = unit;
            assertSaturated(expected = maxInstant(), saturatingAdd(maxInstant(), d),
                            "adding ${name} past the latest instant")
        }, oneOfEachUnit());
        List.forEach(unit -> {
            let (name, d) = unit;
            assertSaturated(expected = minInstant(), saturatingAdd(minInstant(), d),
                            "adding ${name} past the earliest instant")
        }, minusOneOfEachUnit())
    }

}
