///
/// Tests for the `Eq`, `Order` and `Hash` instances of `Instant`.
///
/// They are written by hand rather than derived, because Flix cannot derive
/// traits for an enum whose case holds a record. Each one has to read both
/// fields: `secondsSinceEpoch` decides first and `nano` breaks the tie. They are
/// what let callers sort instants and use them as map keys, so the cases below
/// concentrate on pairs that agree on one field and differ on the other.
///
/// Every test names the test262 case it was adapted from, or says plainly that it
/// has no counterpart there. References are against test262
/// `7710052` (2026-08-30) and are relative to `test/built-ins/Temporal/`.
///
mod Time.Instant.Compare {
    use Time.Instant.Harness.{epoch, instantOf, maxInstant, minInstant, partsOf}

    /// Instants agreeing on both fields are equal.
    ///
    /// Adapted from test262 `Instant/prototype/equals/basic.js` and
    /// `equals/cross-epoch.js`.
    @Test
    def eq01_bothFieldsAgreeing_areEqual(): Unit \ Assert =
        Assert.assertTrue(instantOf(3i64, 1) == instantOf(3i64, 1));
        Assert.assertTrue(epoch() == instantOf(0i64, 0));
        Assert.assertTrue(minInstant() == instantOf(Int64.minValue(), 0));
        Assert.assertTrue(maxInstant() == instantOf(Int64.maxValue(), 999_999_999))

    /// A difference in either field alone is enough to be unequal.
    ///
    /// Adapted from test262 `Instant/prototype/equals/basic.js`, whose two instants
    /// differ only in their sub-second part.
    @Test
    def eq02_eitherFieldDiffering_areNotEqual(): Unit \ Assert =
        Assert.assertTrue(instantOf(3i64, 1) != instantOf(3i64, 2));
        Assert.assertTrue(instantOf(3i64, 1) != instantOf(4i64, 1));
        Assert.assertTrue(instantOf(-1i64, 0) != instantOf(1i64, 0))

    /// `secondsSinceEpoch` decides the ordering, across the epoch and up to the
    /// extremes.
    ///
    /// Adapted from test262 `Instant/compare/exhaustive.js` and
    /// `compare/cross-epoch.js`.
    @Test
    def compare01_differingSeconds_ordersByThem(): Unit \ Assert =
        Assert.assertEq(expected = Comparison.LessThan, instantOf(0i64, 0) <=> instantOf(1i64, 0));
        Assert.assertEq(expected = Comparison.GreaterThan, instantOf(1i64, 0) <=> instantOf(0i64, 0));
        Assert.assertEq(expected = Comparison.LessThan, instantOf(-1i64, 0) <=> instantOf(0i64, 0));
        Assert.assertEq(expected = Comparison.LessThan, minInstant() <=> maxInstant())

    /// A larger `nano` never outranks a larger `secondsSinceEpoch`.
    ///
    /// No test262 counterpart: a `Temporal.Instant` is one signed count of
    /// nanoseconds, so it has no two fields that could be weighed against each other.
    @Test
    def compare02_differingSeconds_ignoresTheNano(): Unit \ Assert =
        Assert.assertTrue(instantOf(0i64, 999_999_999) < instantOf(1i64, 0));
        Assert.assertTrue(instantOf(-1i64, 999_999_999) < instantOf(0i64, 0))

    /// `nano` breaks the tie when the seconds agree.
    ///
    /// Adapted from test262 `Instant/compare/exhaustive.js`.
    @Test
    def compare03_agreeingSeconds_ordersByTheNano(): Unit \ Assert =
        Assert.assertEq(expected = Comparison.LessThan, instantOf(3i64, 1) <=> instantOf(3i64, 2));
        Assert.assertEq(expected = Comparison.GreaterThan, instantOf(3i64, 2) <=> instantOf(3i64, 1));
        Assert.assertEq(expected = Comparison.EqualTo, instantOf(3i64, 1) <=> instantOf(3i64, 1))

    /// The comparison operators agree with the ordering.
    ///
    /// Adapted from test262 `Instant/compare/exhaustive.js`, spelled with the
    /// operators the `Order` instance provides.
    @Test
    def compare04_anyTwoInstants_agreesWithTheOperators(): Unit \ Assert =
        Assert.assertTrue(instantOf(3i64, 1) < instantOf(3i64, 2));
        Assert.assertTrue(instantOf(3i64, 2) > instantOf(3i64, 1));
        Assert.assertTrue(instantOf(3i64, 1) <= instantOf(3i64, 1));
        Assert.assertTrue(instantOf(3i64, 1) >= instantOf(3i64, 1));
        Assert.assertFalse(instantOf(3i64, 1) < instantOf(3i64, 1))

    /// Sorting instants puts the earliest first, with `nano` deciding within a second.
    ///
    /// No test262 counterpart: `Temporal.Instant.compare` exists to be handed to
    /// `Array.prototype.sort`, but test262 does not exercise sorting itself.
    @Test
    def compare05_aListOfInstants_sortsEarliestFirst(): Unit \ Assert =
        let sorted = List.sort(List#{
            instantOf(2i64, 0), instantOf(-1i64, 999_999_999), instantOf(0i64, 0),
            instantOf(2i64, 1), instantOf(0i64, 1)
        });
        Assert.assertEq(expected = List#{(-1i64, 999_999_999), (0i64, 0), (0i64, 1), (2i64, 0), (2i64, 1)},
                        List.map(partsOf, sorted))

    /// Equal instants hash equally, so they can be used as map keys.
    ///
    /// No test262 counterpart: JavaScript has no `Hash` instance to write.
    @Test
    def hash01_equalInstants_hashEqually(): Unit \ Assert =
        Assert.assertEq(expected = Hash.hash(instantOf(1_735_689_600i64, 123_456_789)),
                        Hash.hash(instantOf(1_735_689_600i64, 123_456_789)))

    /// `nano` reaches the hash, so instants within one second are not all collisions.
    ///
    /// No test262 counterpart, for the same reason as `hash01`.
    @Test
    def hash02_instantsDifferingOnlyInTheNano_hashDifferently(): Unit \ Assert =
        Assert.assertNeqWithMsg(unexpected = Hash.hash(instantOf(3i64, 1)), Hash.hash(instantOf(3i64, 2)),
                                "the nano does not reach the hash, so every instant in a second collides")
}
