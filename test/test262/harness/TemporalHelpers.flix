///
/// Helpers shared by the ported test262 cases.
///
/// This mirrors test262's own `harness/temporalHelpers.js`, which the ported files
/// pull in with an `includes: [temporalHelpers.js]` header.
///
/// The module has to be `pub` for the test files to `use` it, and Flix requires a
/// `pub mod` to sit at a path that matches its name, which is why this file is
/// `TemporalHelpers.flix` rather than the lower-case name test262 gives it.
///
/// It only plays the same role. None of the code below is taken or translated from
/// test262's harness, so this file carries no test262 copyright notice and is under this
/// repository's own licence. The ported cases beside it do carry one; see
/// `test/test262/LICENSE`.
///
pub mod TemporalHelpers {

    use Time.Duration
    use Time.Instant.Instant

    ///
    /// Builds an `Instant` from the two fields it is stored in.
    ///
    /// `Temporal.Instant` is a single signed nanosecond count, so every expectation
    /// taken from test262 has to be re-expressed as a (second, nanosecond-of-second)
    /// pair. Each ported case shows that arithmetic in its doc comment.
    ///
    pub def instant(secondsSinceEpoch: Int64, nano: Int32): Instant =
        Instant({secondsSinceEpoch = secondsSinceEpoch, nano = nano})

    /// 1970-01-01T00:00:00Z.
    pub def epoch(): Instant = instant(0i64, 0)

    ///
    /// The earliest representable `Instant`.
    ///
    /// `Temporal.Instant` is limited to -8.64e21 nanoseconds; here the limit is
    /// instead the smallest `Int64` second, with no room left in `nano` below it.
    ///
    pub def minInstant(): Instant = instant(Int64.minValue(), 0)

    ///
    /// The latest representable `Instant`.
    ///
    /// `nano` is at its ceiling as well, so there is not one nanosecond of room above it.
    ///
    pub def maxInstant(): Instant = instant(Int64.maxValue(), 999_999_999)

    ///
    /// Stands in for test262's `new Temporal.Instant(ns)`.
    ///
    /// The split is done here rather than through `Time.Instant.fromEpochNanoseconds`
    /// so that a case about `tryAdd` (say) does not silently depend on that function
    /// being correct. `ns` is divided towards negative infinity, which keeps the
    /// remainder — and therefore `nano` — non-negative.
    ///
    pub def fromNanos(ns: Int64): Instant =
        let q = ns / 1_000_000_000i64;
        let seconds = if (Int64.remainder(ns, 1_000_000_000i64) < 0i64) q - 1i64 else q;
        instant(seconds, Int64.truncateToInt32(Int64.modulo(ns, 1_000_000_000i64)))

    ///
    /// Exposes the two fields of `t`.
    ///
    /// `Instant` holds a record, so Flix cannot derive `ToString` for it and it cannot be
    /// handed to `Assert.assertEq` directly. Comparing the pair also reports which of the
    /// two numbers went wrong when a case fails.
    ///
    pub def parts(t: Instant): (Int64, Int32) =
        let Instant(i) = t;
        (i#secondsSinceEpoch, i#nano)

    ///
    /// The count `t` would report as `Temporal.Instant.prototype.epochMilliseconds`:
    /// whole milliseconds since the epoch, rounded towards negative infinity.
    ///
    /// Only meaningful for instants whose second count is small enough that
    /// `secondsSinceEpoch * 1000` fits in an `Int64`.
    ///
    pub def epochMilliseconds(t: Instant): Int64 =
        let (seconds, nano) = parts(t);
        seconds * 1_000i64 + Int32.toInt64(nano) / 1_000_000i64

    ///
    /// The count `t` would report as `Temporal.Instant.prototype.epochNanoseconds`.
    ///
    /// Only meaningful for instants whose distance from the epoch fits in an `Int64`,
    /// which is a far narrower range than `Instant` itself covers.
    ///
    pub def epochNanoseconds(t: Instant): Int64 =
        let (seconds, nano) = parts(t);
        seconds * 1_000_000_000i64 + Int32.toInt64(nano)

    /// test262's `TemporalHelpers.assertInstantsEqual`.
    pub def assertInstantsEqual(expected: {expected = Instant}, actual: Instant, msg: String): Unit \ Assert =
        let e = parts(expected#expected);
        let a = parts(actual);
        Assert.assertEqWithMsg(expected = e, a, "${msg}: expected ${e}, got ${a}")

    ///
    /// `assertInstantsEqual` for the `try` operations, which answer with an `Option`
    /// where `Temporal` returns the instant or throws.
    ///
    pub def assertSomeInstant(expected: {expected = Instant}, actual: Option[Instant], msg: String): Unit \ Assert =
        let e = Some(parts(expected#expected));
        let a = Option.map(parts, actual);
        Assert.assertEqWithMsg(expected = e, a, "${msg}: expected ${e}, got ${a}")

    ///
    /// Stands in for test262's `assert.throws(RangeError, ...)`.
    ///
    /// Where `Temporal` throws for a result outside the representable range, the `try`
    /// operations here answer `None` instead.
    ///
    pub def assertNoInstant(actual: Option[Instant], msg: String): Unit \ Assert =
        let a = Option.map(parts, actual);
        Assert.assertEqWithMsg(expected = None, a, "${msg}: expected None, got ${a}")

    ///
    /// The other half of test262's `assert.throws(RangeError, ...)`.
    ///
    /// The `saturating` operations answer with the nearest representable instant
    /// rather than failing, so a case that expects a `RangeError` in test262 turns
    /// into two here: `assertNoInstant` for `try`, and this one for `saturating`.
    ///
    pub def assertSaturated(expected: {expected = Instant}, actual: Instant, msg: String): Unit \ Assert =
        assertInstantsEqual(expected = expected#expected, actual, msg)

    ///
    /// test262's `TemporalHelpers.assertDurationsEqual`, for the `Option[Duration]`
    /// that `between` answers with.
    ///
    pub def assertSomeDuration(expected: {expected = Duration}, actual: Option[Duration], msg: String): Unit \ Assert =
        Assert.assertEqWithMsg(expected = Some(expected#expected), actual, "${msg}: expected ${Some(expected#expected)}, got ${actual}")

    ///
    /// `between` answers `None` for a gap too wide to fit in a `Duration`. test262 has
    /// no counterpart: `since` and `until` return an arbitrary-precision `Duration`.
    ///
    pub def assertNoDuration(actual: Option[Duration], msg: String): Unit \ Assert =
        Assert.assertEqWithMsg(expected = None, actual, "${msg}: expected None, got ${actual}")

}
