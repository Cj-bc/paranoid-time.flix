// Copyright (C) 2021 Igalia, S.L. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.Instant; the module doc comment says what changed.
///
/// Ported from test262
/// `test/built-ins/Temporal/Instant/prototype/subtract/result-out-of-range.js`
/// (esid: sec-temporal.instant.prototype.subtract).
///
/// test262 walks the six sub-day units and expects a `RangeError` for each of them, once
/// downwards from the earliest instant and once upwards from the latest one. Each of those
/// becomes two checks here: `trySub` answers `None`, and `saturatingSub` answers the end it
/// ran into.
///
mod Test262.BuiltIns.Temporal.Instant.Prototype.Subtract.ResultOutOfRange {

    use TemporalHelpers.assertNoInstant
    use TemporalHelpers.assertSaturated
    use TemporalHelpers.maxInstant
    use TemporalHelpers.minInstant
    use Time.Duration
    use Time.Instant.saturatingSub
    use Time.Instant.trySub

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

    /// test262: `earliest.subtract({ [field]: 1 })` throws for each field.
    @Test
    def subtract01_oneOfAnyUnitAtTheEarliestInstant_isOutOfRange(): Unit \ Assert =
        List.forEach(unit -> {
            let (name, d) = unit;
            assertNoInstant(trySub(minInstant(), d), "subtracting ${name} with result out of range (negative)")
        }, oneOfEachUnit())

    /// test262: `latest.subtract({ [field]: -1 })` throws for each field.
    @Test
    def subtract02_minusOneOfAnyUnitAtTheLatestInstant_isOutOfRange(): Unit \ Assert =
        List.forEach(unit -> {
            let (name, d) = unit;
            assertNoInstant(trySub(maxInstant(), d), "subtracting ${name} with result out of range (positive)")
        }, minusOneOfEachUnit())

    ///
    /// The `saturating` half of the two cases above, which test262 has no counterpart for.
    ///
    @Test
    def subtract03_pastEitherEnd_saturatesToThatEnd(): Unit \ Assert = {
        List.forEach(unit -> {
            let (name, d) = unit;
            assertSaturated(expected = minInstant(), saturatingSub(minInstant(), d),
                            "subtracting ${name} past the earliest instant")
        }, oneOfEachUnit());
        List.forEach(unit -> {
            let (name, d) = unit;
            assertSaturated(expected = maxInstant(), saturatingSub(maxInstant(), d),
                            "subtracting ${name} past the latest instant")
        }, minusOneOfEachUnit())
    }

}
