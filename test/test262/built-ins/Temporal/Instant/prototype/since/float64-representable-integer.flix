///
/// Ported from test262
/// `test/built-ins/Temporal/Instant/prototype/since/float64-representable-integer.js`
/// (esid: sec-temporal.instant.prototype.since).
///
/// test262 takes a gap of 2^64 nanoseconds — more than a `Number` can name exactly — and
/// checks that `since` reports it with the precision the spec prescribes rather than with
/// whatever the implementation happens to hold internally.
///
/// The limit here is a different one, and harder: `between` answers a `Time.Duration`, which
/// is an `Int64` nanosecond count, so a gap it cannot name is not reported imprecisely but
/// not reported at all — `None`. This file pins where that boundary falls.
///
/// 2^64 ns is 18446744073709551616 ns, which is 18446744073 seconds plus 709551616 ns.
///
mod Test262.BuiltIns.Temporal.Instant.Prototype.Since.Float64RepresentableInteger {

    use TemporalHelpers.assertNoDuration
    use TemporalHelpers.assertSomeDuration
    use TemporalHelpers.epoch
    use TemporalHelpers.instant
    use TemporalHelpers.maxInstant
    use TemporalHelpers.minInstant
    use Time.Duration
    use Time.Instant.between

    ///
    /// test262's `i1.since(i2)` over a gap of 2^64 nanoseconds.
    ///
    /// `Int64.maxValue()` is about 9.22e18 ns, so a gap of 1.84e19 ns has no `Duration`.
    ///
    @Test
    def since01_aGapOfTwoToTheSixtyFourNanoseconds_hasNoDuration(): Unit \ Assert =
        assertNoDuration(between(epoch(), instant(18_446_744_073i64, 709_551_616)),
                         "a gap of 2^64 nanoseconds")

    ///
    /// The largest gap that does have a `Duration` is `Int64.maxValue()` nanoseconds, which
    /// is 9223372036 seconds plus 854775807 ns after the epoch.
    ///
    /// No test262 counterpart: `Temporal.Duration` has no such ceiling.
    ///
    @Test
    def since02_theLargestGapThatFits_isReported(): Unit \ Assert =
        assertSomeDuration(expected = Duration.nanoseconds(Int64.maxValue()),
                           between(epoch(), instant(9_223_372_036i64, 854_775_807)),
                           "the largest gap that fits in a Duration")

    /// One nanosecond further and there is no `Duration` for it.
    @Test
    def since03_oneNanosecondPastTheLargestGap_hasNoDuration(): Unit \ Assert =
        assertNoDuration(between(epoch(), instant(9_223_372_036i64, 854_775_808)),
                         "one nanosecond past the largest gap that fits")

    ///
    /// The whole range is far wider than any `Duration`, so its ends have no gap either.
    ///
    @Test
    def since04_theWholeRange_hasNoDuration(): Unit \ Assert = {
        assertNoDuration(between(minInstant(), maxInstant()), "the earliest against the latest instant");
        assertNoDuration(between(minInstant(), epoch()), "the earliest instant against the epoch");
        assertNoDuration(between(epoch(), maxInstant()), "the epoch against the latest instant")
    }

    ///
    /// A gap of 9223372036000000001 ns fits in a `Duration` — it is 854775806 ns under
    /// `Int64.maxValue()` — and so should be reported.
    ///
    /// It is spread as 9223372037 whole seconds minus 999999999 nanoseconds, which is one
    /// second more than any gap looked at above. `between` rejects a second count over
    /// 9223372036 outright, before the nanosecond difference is allowed to bring it back
    /// under the ceiling, so it answers `None` here for a gap it can name.
    ///
    /// This case fails against the implementation as it stands. It is written to the
    /// documented contract — "the absolute amount of time between `d1` and `d2`, or `None`
    /// when it is too large to fit in a `Duration`" — rather than to the current behaviour.
    ///
    /// No test262 counterpart: the ceiling it probes does not exist there.
    ///
    @Test
    def since05_aGapJustUnderTheCeilingSpreadOverAnExtraSecond_isReported(): Unit \ Assert =
        assertSomeDuration(expected = Duration.nanoseconds(9_223_372_036_000_000_001i64),
                           between(instant(0i64, 999_999_999), instant(9_223_372_037i64, 0)),
                           "a gap of 9223372036000000001 nanoseconds")

}
