pub mod Time.Instant {
  use Time.Clock
  use Time.Duration
  use Time.TimeUnit

  /// Keeps time in milliseconds since the epoch
  pub enum Instant(Int64) with Eq, Order, Hash

  pub def now(): Instant \ Clock =
    Instant(Clock.now())

  pub def add(date: Instant, d: Duration): Instant =
    let Instant(t) = date;
    Instant(t + Duration.toMillis(d))

  pub def sub(date: Instant, d: Duration): Instant =
    let Instant(t) = date;
    Instant(t - Duration.toMillis(d))

  pub def between(d1: Instant, d2: Instant): Duration =
    let Instant(t1) = d1;
    let Instant(t2) = d2;
    Duration.Duration(Int64.abs(t1 - t2))
}
