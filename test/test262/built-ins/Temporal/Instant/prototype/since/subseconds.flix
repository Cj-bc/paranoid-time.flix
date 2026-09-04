// Copyright (C) 2022 Igalia, S.L. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.Instant; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/Instant/prototype/since/subseconds.js`
/// (esid: sec-temporal.instant.prototype.since).
///
/// test262 asks for the same gap three times over, with `largestUnit` set to milliseconds,
/// microseconds and nanoseconds, and checks how it is spread across the duration's fields.
/// `between` has no `largestUnit`: it answers one `Duration`, which is a nanosecond count.
/// The three readings become `Duration.toMillis`, `toMicros` and `toNanos` of that one
/// answer, which truncate towards zero and so reproduce test262's three largest fields.
///
/// The timestamp test262 names is spelled out as the pair it denotes:
///
///   2020-02-01T00:00:00Z -> (1580515200, 0)
///
mod Test262.BuiltIns.Temporal.Instant.Prototype.Since.Subseconds {

    use TemporalHelpers.assertSomeDuration
    use TemporalHelpers.assertSomeInstant
    use TemporalHelpers.instant
    use Time.Duration
    use Time.Instant.Instant
    use Time.Instant.between
    use Time.Instant.tryAdd

    /// 2020-02-01T00:00:00Z.
    def feb20(): Instant = instant(1_580_515_200i64, 0)

    /// test262's `{ hours: 24, milliseconds: 250, microseconds: 250, nanoseconds: 250 }`.
    def shift(): Duration =
        Duration.hours(24) + Duration.milliseconds(250) + Duration.microseconds(250)
          + Duration.nanoseconds(250i64)

    ///
    /// test262's `latersub`, 24 hours and 250250250 ns after `feb20`.
    ///
    /// 1580515200 + 86400 = 1580601600 seconds, and the sub-second part is
    /// 250 ms + 250 us + 250 ns = 250250250 ns.
    ///
    def latersub(): Instant = instant(1_580_601_600i64, 250_250_250)

    /// Pins the starting point of the three readings below, which test262 builds with `add`.
    @Test
    def since01_theShift_reachesLatersub(): Unit \ Assert =
        assertSomeInstant(expected = latersub(), tryAdd(feb20(), shift()),
                          "feb20.add({ hours: 24, milliseconds: 250, microseconds: 250, nanoseconds: 250 })")

    ///
    /// test262 with `largestUnit: "nanoseconds"`: 86400250250250 nanoseconds.
    ///
    /// 86400 seconds is 86400000000000 ns, plus the 250250250 ns of sub-second part.
    ///
    @Test
    def since02_theGap_isThatManyNanoseconds(): Unit \ Assert =
        assertSomeDuration(expected = Duration.nanoseconds(86_400_250_250_250i64),
                           between(latersub(), feb20()), "largestUnit: nanoseconds")

    ///
    /// test262 with `largestUnit: "microseconds"`: 86400250250 microseconds and 250
    /// nanoseconds. `Duration.toMicros` truncates, so it answers the 86400250250.
    ///
    @Test
    def since03_theGap_isThatManyWholeMicroseconds(): Unit \ Assert =
        Assert.assertEq(expected = Some(86_400_250_250i64),
                        between(latersub(), feb20()) |> Option.map(Duration.toMicros))

    ///
    /// test262 with `largestUnit: "milliseconds"`: 86400250 milliseconds, 250 microseconds
    /// and 250 nanoseconds. `Duration.toMillis` truncates, so it answers the 86400250.
    ///
    @Test
    def since04_theGap_isThatManyWholeMilliseconds(): Unit \ Assert =
        Assert.assertEq(expected = Some(86_400_250i64),
                        between(latersub(), feb20()) |> Option.map(Duration.toMillis))

}
