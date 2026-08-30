///
/// Shared helpers for the `Time.Instant` test suite.
///
/// `Instant` only derives `Eq`, `Order` and `Hash`, so it cannot be handed to
/// `Assert.assertEq` directly. These helpers unwrap it into the milliseconds it
/// carries, which keeps the assertions comparable *and* makes a failure report
/// the two numbers that actually differ.
///
pub mod Time.Instant.Harness {
    use Time.Instant.Instant

    /// Builds an `Instant` holding `ms` milliseconds since the epoch.
    pub def instantOf(ms: Int64): Instant = Instant.Instant(ms)

    /// Returns the milliseconds since the epoch held by `t`.
    pub def millisOf(t: Instant): Int64 =
        let Instant.Instant(ms) = t;
        ms

    /// Lifts `millisOf` over `Option`, for the `try*` functions.
    pub def millisOfOpt(t: Option[Instant]): Option[Int64] = Option.map(millisOf, t)
}
