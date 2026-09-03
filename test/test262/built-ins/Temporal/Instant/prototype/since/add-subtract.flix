///
/// Ported from test262 `test/built-ins/Temporal/Instant/prototype/since/add-subtract.js`
/// (esid: sec-temporal.instant.prototype.since).
///
/// The counterpart of `since` and `until` is `between`, which differs from both in two ways:
/// it answers the *absolute* gap, so the two arguments can be given in either order, and it
/// answers an `Option`, since a gap too wide for a `Duration` has no answer at all.
///
/// The two timestamps test262 names are spelled out as the pairs they denote:
///
///   1976-11-18T15:23:30.123456789Z -> ( 217178610, 123456789)
///   2019-10-29T10:46:38.271986102Z -> (1572345998, 271986102)
///
/// The gap between them is 1572345998 - 217178610 = 1355167388 seconds plus
/// 271986102 - 123456789 = 148529313 nanoseconds, which is 1355167388148529313 ns.
///
mod Test262.BuiltIns.Temporal.Instant.Prototype.Since.AddSubtract {

    use TemporalHelpers.assertSomeDuration
    use TemporalHelpers.assertSomeInstant
    use TemporalHelpers.instant
    use Time.Duration
    use Time.Instant.Instant
    use Time.Instant.between
    use Time.Instant.tryAdd
    use Time.Instant.trySub

    /// 1976-11-18T15:23:30.123456789Z.
    def earlier(): Instant = instant(217_178_610i64, 123_456_789)

    /// 2019-10-29T10:46:38.271986102Z.
    def later(): Instant = instant(1_572_345_998i64, 271_986_102)

    /// test262's `diff`, the gap between the two.
    def diff(): Duration = Duration.nanoseconds(1_355_167_388_148_529_313i64)

    /// test262: `later.since(earlier)` is `diff`.
    @Test
    def since01_theLaterInstantFirst_isTheGapBetweenThem(): Unit \ Assert =
        assertSomeDuration(expected = diff(), between(later(), earlier()), "later.since(earlier)")

    ///
    /// test262: `earlier.since(later)` is `diff.negated()`, and `earlier.until(later)` is
    /// `diff`.
    ///
    /// `between` is unsigned, so swapping the arguments answers the same duration rather
    /// than the negated one. That is the property it has in place of test262's pair.
    ///
    @Test
    def since02_theEarlierInstantFirst_isTheSameGap(): Unit \ Assert =
        assertSomeDuration(expected = diff(), between(earlier(), later()), "earlier.since(later)")

    /// test262: `earlier.add(diff)` is `later`.
    @Test
    def since03_addingTheGapToTheEarlier_reachesTheLater(): Unit \ Assert =
        assertSomeInstant(expected = later(), tryAdd(earlier(), diff()), "earlier.add(diff)")

    /// test262: `later.subtract(diff)` is `earlier`.
    @Test
    def since04_subtractingTheGapFromTheLater_reachesTheEarlier(): Unit \ Assert =
        assertSomeInstant(expected = earlier(), trySub(later(), diff()), "later.subtract(diff)")

}
