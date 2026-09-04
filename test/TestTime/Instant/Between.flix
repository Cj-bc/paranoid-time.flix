///
/// Tests for `between` that test262 has no counterpart for.
///
/// `since` and `until` are signed and answer an arbitrary-precision `Temporal.Duration`;
/// `between` answers the *absolute* gap as an `Option[Duration]`, where `Duration` is an
/// `Int64` nanosecond count. Two properties follow that `Temporal` cannot state: the answer is
/// never negative, and there is a ceiling above which there is no answer at all.
///
/// The instant builders and assertions come from the test262 harness rather than being
/// written out again here.
///
mod TestTime.Instant.Between {

    use TemporalHelpers.assertNoDuration
    use TemporalHelpers.assertSomeDuration
    use TemporalHelpers.epoch
    use TemporalHelpers.instant
    use TemporalHelpers.maxInstant
    use TemporalHelpers.minInstant
    use Time.Duration
    use Time.Instant.between

    ///
    /// The gap is zero at the two ends of the range as well, rather than overflowing on the way
    /// to the subtraction.
    ///
    @Test
    def between01_eitherEndAgainstItself_yieldsTheZeroDuration(): Unit \ Assert = {
        assertSomeDuration(expected = Duration.zero(), between(minInstant(), minInstant()),
                           "the earliest instant against itself");
        assertSomeDuration(expected = Duration.zero(), between(maxInstant(), maxInstant()),
                           "the latest instant against itself");
        assertSomeDuration(expected = Duration.zero(), between(epoch(), epoch()), "the epoch against itself")
    }

    ///
    /// The largest gap that does have a `Duration` is `Int64.maxValue()` nanoseconds, which is
    /// 9223372036 seconds plus 854775807 ns after the epoch.
    ///
    @Test
    def between02_theLargestGapThatFits_isReported(): Unit \ Assert =
        assertSomeDuration(expected = Duration.nanoseconds(Int64.maxValue()),
                           between(epoch(), instant(9_223_372_036i64, 854_775_807)),
                           "the largest gap that fits in a Duration")

    /// One nanosecond further and there is no `Duration` for it.
    @Test
    def between03_oneNanosecondPastTheLargestGap_hasNoDuration(): Unit \ Assert =
        assertNoDuration(between(epoch(), instant(9_223_372_036i64, 854_775_808)),
                         "one nanosecond past the largest gap that fits")

    /// The whole range is far wider than any `Duration`, so its ends have no gap either.
    @Test
    def between04_theWholeRange_hasNoDuration(): Unit \ Assert = {
        assertNoDuration(between(minInstant(), maxInstant()), "the earliest against the latest instant");
        assertNoDuration(between(minInstant(), epoch()), "the earliest instant against the epoch");
        assertNoDuration(between(epoch(), maxInstant()), "the epoch against the latest instant")
    }

    ///
    /// `between` never answers a negative duration, whichever order it is given.
    ///
    /// The sign is exactly what the absolute form has to get right, at the ends of the range as
    /// much as in the middle. The two dated instants are those of test262's
    /// `prototype/since/add-subtract.js`.
    ///
    @Test
    def between05_anyPairOfInstants_yieldsANonNegativeDuration(): Unit \ Assert = {
        // 1976-11-18T15:23:30.123456789Z and 2019-10-29T10:46:38.271986102Z.
        let earlier = instant(217_178_610i64, 123_456_789);
        let later = instant(1_572_345_998i64, 271_986_102);
        let pairs =
            (earlier, later) ::
            (later, earlier) ::
            (minInstant(), epoch()) ::
            (epoch(), minInstant()) ::
            (maxInstant(), epoch()) ::
            (instant(-1i64, 999_999_999), instant(0i64, 0)) ::
            (instant(0i64, 0), instant(-1i64, 999_999_999)) ::
            Nil;
        List.forEach(pair -> {
            let (a, b) = pair;
            match between(a, b) {
                case None    => ()
                case Some(d) => Assert.assertFalseWithMsg(Duration.isNegative(d),
                                                          "between answered the negative duration ${d}")
            }
        }, pairs)
    }

    ///
    /// A gap of 9223372036000000001 ns fits in a `Duration` — it is 854775806 ns under
    /// `Int64.maxValue()` — and so should be reported.
    ///
    /// It is spread as 9223372037 whole seconds minus 999999999 nanoseconds, which is one second
    /// more than any gap looked at above. `between` rejects a second count over 9223372036
    /// outright, before the nanosecond difference is allowed to bring it back under the ceiling,
    /// so it answers `None` here for a gap it can name.
    ///
    /// This case fails against the implementation as it stands. It is written to the documented
    /// contract — "the absolute amount of time between `d1` and `d2`, or `None` when it is too
    /// large to fit in a `Duration`" — rather than to the current behaviour.
    ///
    @Test
    def between06_aGapJustUnderTheCeilingSpreadOverAnExtraSecond_isReported(): Unit \ Assert =
        assertSomeDuration(expected = Duration.nanoseconds(9_223_372_036_000_000_001i64),
                           between(instant(0i64, 999_999_999), instant(9_223_372_037i64, 0)),
                           "a gap of 9223372036000000001 nanoseconds")

}
