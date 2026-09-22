// Copyright (C) 2018 Bloomberg LP. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.Instant; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/Instant/fromEpochMilliseconds/limits.js`
/// (esid: sec-temporal.instant.fromepochmilliseconds, "Min/max range").
///
/// test262 accepts +/-8640000000000000 ms and expects a `RangeError` one millisecond
/// outside either of them. The range here is a calendar one — -9999-01-02T00:00:00Z to
/// 9999-12-30T23:59:59.999999999Z — so the two numbers are different, but the shape of the
/// case carries over unchanged: the last millisecond inside an end is split as given, and
/// one further out is not representable.
///
/// As everywhere else, out of range is not a throw but two operations: the `try` form
/// answers `None`, and `saturatingOfEpochMilli` clamps to the end it ran into.
///
/// The top end is the one place the two forms of the limit do not meet: the latest instant
/// is 999999999 ns into its second and a millisecond count cannot name that, so the last
/// count inside the range lands 999 microseconds short of it.
///
mod Test262.BuiltIns.Temporal.Instant.FromEpochMilliseconds.Limits {

    use TemporalHelpers.{assertInstantsEqual, assertNoInstant, assertSomeInstant, instant}
    use Time.Instant.{max, min, saturatingOfEpochMilli, tryOfEpochMilli}

    /// -9999-01-02T00:00:00Z is -377705116800 whole seconds after the epoch.
    def earliestMillis(): Int64 = -377_705_116_800_000i64

    /// The last whole millisecond of 9999-12-30, 253402214399 s plus 999 ms.
    def latestMillis(): Int64 = 253_402_214_399_999i64

    /// test262: `Temporal.Instant.fromEpochMilliseconds(+/-8640000000000000)` is fine.
    @Test
    def fromEpochMilliseconds01_theLastCountInsideEitherEnd_isSplitAsGiven(): Unit \ Assert = {
        assertInstantsEqual(expected = min(), saturatingOfEpochMilli(earliestMillis()),
                            "the earliest millisecond count in range");
        assertInstantsEqual(expected = instant(253_402_214_399i64, 999_000_000),
                            saturatingOfEpochMilli(latestMillis()),
                            "the latest millisecond count in range")
    }

    /// The `try` half of the case above.
    @Test
    def fromEpochMilliseconds02_theLastCountInsideEitherEnd_hasAnInstant(): Unit \ Assert = {
        assertSomeInstant(expected = min(), tryOfEpochMilli(earliestMillis()),
                          "the earliest millisecond count in range");
        assertSomeInstant(expected = instant(253_402_214_399i64, 999_000_000),
                          tryOfEpochMilli(latestMillis()),
                          "the latest millisecond count in range")
    }

    /// test262: one millisecond further out throws; here the `try` form answers `None`.
    @Test
    def fromEpochMilliseconds03_oneMillisecondOutsideEitherEnd_hasNoInstant(): Unit \ Assert = {
        assertNoInstant(tryOfEpochMilli(earliestMillis() - 1i64),
                        "one millisecond before the earliest instant");
        assertNoInstant(tryOfEpochMilli(latestMillis() + 1i64),
                        "one millisecond after the latest instant");
        assertNoInstant(tryOfEpochMilli(Int64.minValue()),
                        "the smallest millisecond count");
        assertNoInstant(tryOfEpochMilli(Int64.maxValue()),
                        "the largest millisecond count")
    }

    ///
    /// The `saturating` half, which test262 has no counterpart for: one millisecond further
    /// out clamps to that end rather than failing.
    ///
    @Test
    def fromEpochMilliseconds04_oneMillisecondOutsideEitherEnd_clampsToThatEnd(): Unit \ Assert = {
        assertInstantsEqual(expected = min(), saturatingOfEpochMilli(earliestMillis() - 1i64),
                            "one millisecond before the earliest instant");
        assertInstantsEqual(expected = max(), saturatingOfEpochMilli(latestMillis() + 1i64),
                            "one millisecond after the latest instant")
    }

    ///
    /// The same from as far outside as an `Int64` millisecond count reaches, about 9.2e15
    /// seconds either way against a range of about 3.8e11.
    ///
    /// The split still has to be done before the clamp can be decided, so this is also what
    /// pins that it is done without overflowing.
    ///
    @Test
    def fromEpochMilliseconds05_theTwoEndsOfInt64_clampWithoutOverflowing(): Unit \ Assert = {
        assertInstantsEqual(expected = min(), saturatingOfEpochMilli(Int64.minValue()),
                            "the smallest millisecond count");
        assertInstantsEqual(expected = max(), saturatingOfEpochMilli(Int64.maxValue()),
                            "the largest millisecond count")
    }

}
