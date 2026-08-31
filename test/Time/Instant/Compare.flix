///
/// Tests for the `Eq`, `Order` and `Hash` instances derived for `Instant`.
///
/// They are what let callers sort instants and use them as map keys, so they
/// have to follow the millisecond value the instant carries.
///
/// Every test names the test262 case it was adapted from, or says plainly that it
/// has no counterpart there. References are against test262
/// `7710052` (2026-08-30) and are relative to `test/built-ins/Temporal/`.
///
mod Time.Instant.Compare {
    use Time.Instant.Harness.instantOf

    /// Instants holding the same millisecond are equal.
    ///
    /// Adapted from test262 `Instant/prototype/equals/basic.js` and
    /// `equals/cross-epoch.js`.
    @Test
    def compare01_equalInstants(): Unit \ Assert =
        Assert.assertTrue(instantOf(1_234i64) == instantOf(1_234i64));
        Assert.assertTrue(instantOf(0i64) == instantOf(0i64));
        Assert.assertTrue(instantOf(Int64.minValue()) == instantOf(Int64.minValue()))

    /// Instants holding different milliseconds are not equal.
    ///
    /// Adapted from test262 `Instant/prototype/equals/basic.js`.
    @Test
    def compare02_differentInstants(): Unit \ Assert =
        Assert.assertFalse(instantOf(1_234i64) == instantOf(1_235i64));
        Assert.assertTrue(instantOf(-1i64) != instantOf(1i64))

    /// The ordering follows the millisecond value, across the epoch and up to
    /// the extremes.
    ///
    /// Adapted from test262 `Instant/compare/exhaustive.js` and `compare/cross-epoch.js`.
    @Test
    def compare03_ordersByMilliseconds(): Unit \ Assert =
        Assert.assertEq(expected = Comparison.LessThan, instantOf(0i64) <=> instantOf(1i64));
        Assert.assertEq(expected = Comparison.GreaterThan, instantOf(1i64) <=> instantOf(0i64));
        Assert.assertEq(expected = Comparison.EqualTo, instantOf(1i64) <=> instantOf(1i64));
        Assert.assertEq(expected = Comparison.LessThan, instantOf(-1i64) <=> instantOf(0i64));
        Assert.assertEq(expected = Comparison.LessThan, instantOf(Int64.minValue()) <=> instantOf(Int64.maxValue()))

    /// The comparison operators agree with the ordering.
    ///
    /// Adapted from test262 `Instant/compare/exhaustive.js`, spelled with the operators
    /// the derived `Order` instance provides.
    @Test
    def compare04_comparisonOperators(): Unit \ Assert =
        Assert.assertTrue(instantOf(0i64) < instantOf(1i64));
        Assert.assertTrue(instantOf(1i64) > instantOf(0i64));
        Assert.assertTrue(instantOf(1i64) <= instantOf(1i64));
        Assert.assertTrue(instantOf(1i64) >= instantOf(1i64));
        Assert.assertFalse(instantOf(1i64) < instantOf(1i64))

    /// Sorting instants puts the earliest first.
    ///
    /// No test262 counterpart: `Temporal.Instant.compare` exists to be handed to
    /// `Array.prototype.sort`, but test262 does not exercise sorting itself.
    @Test
    def compare05_sorts(): Unit \ Assert =
        let sorted = List.sort(List#{instantOf(2i64), instantOf(-1i64), instantOf(0i64)});
        Assert.assertEq(expected = List#{-1i64, 0i64, 2i64}, List.map(Time.Instant.Harness.millisOf, sorted))

    /// Equal instants hash equally, so they can be used as map keys.
    ///
    /// No test262 counterpart: JavaScript has no `Hash` instance to derive.
    @Test
    def compare06_equalInstantsHashEqually(): Unit \ Assert =
        Assert.assertEq(expected = Hash.hash(instantOf(1_234i64)), Hash.hash(instantOf(1_234i64)))
}
