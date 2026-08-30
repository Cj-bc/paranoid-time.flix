///
/// Tests for the `Eq`, `Order` and `Hash` instances derived for `Instant`.
///
/// They are what let callers sort instants and use them as map keys, so they
/// have to follow the millisecond value the instant carries.
///
mod Time.Instant.Compare {
    use Time.Instant.Harness.instantOf

    /// Instants holding the same millisecond are equal.
    @Test
    def compare01_equalInstants(): Unit \ Assert =
        Assert.assertTrue(instantOf(1_234i64) == instantOf(1_234i64));
        Assert.assertTrue(instantOf(0i64) == instantOf(0i64));
        Assert.assertTrue(instantOf(Int64.minValue()) == instantOf(Int64.minValue()))

    /// Instants holding different milliseconds are not equal.
    @Test
    def compare02_differentInstants(): Unit \ Assert =
        Assert.assertFalse(instantOf(1_234i64) == instantOf(1_235i64));
        Assert.assertTrue(instantOf(-1i64) != instantOf(1i64))

    /// The ordering follows the millisecond value, across the epoch and up to
    /// the extremes.
    @Test
    def compare03_ordersByMilliseconds(): Unit \ Assert =
        Assert.assertEq(expected = Comparison.LessThan, instantOf(0i64) <=> instantOf(1i64));
        Assert.assertEq(expected = Comparison.GreaterThan, instantOf(1i64) <=> instantOf(0i64));
        Assert.assertEq(expected = Comparison.EqualTo, instantOf(1i64) <=> instantOf(1i64));
        Assert.assertEq(expected = Comparison.LessThan, instantOf(-1i64) <=> instantOf(0i64));
        Assert.assertEq(expected = Comparison.LessThan, instantOf(Int64.minValue()) <=> instantOf(Int64.maxValue()))

    /// The comparison operators agree with the ordering.
    @Test
    def compare04_comparisonOperators(): Unit \ Assert =
        Assert.assertTrue(instantOf(0i64) < instantOf(1i64));
        Assert.assertTrue(instantOf(1i64) > instantOf(0i64));
        Assert.assertTrue(instantOf(1i64) <= instantOf(1i64));
        Assert.assertTrue(instantOf(1i64) >= instantOf(1i64));
        Assert.assertFalse(instantOf(1i64) < instantOf(1i64))

    /// Sorting instants puts the earliest first.
    @Test
    def compare05_sorts(): Unit \ Assert =
        let sorted = List.sort(List#{instantOf(2i64), instantOf(-1i64), instantOf(0i64)});
        Assert.assertEq(expected = List#{-1i64, 0i64, 2i64}, List.map(Time.Instant.Harness.millisOf, sorted))

    /// Equal instants hash equally, so they can be used as map keys.
    @Test
    def compare06_equalInstantsHashEqually(): Unit \ Assert =
        Assert.assertEq(expected = Hash.hash(instantOf(1_234i64)), Hash.hash(instantOf(1_234i64)))
}
