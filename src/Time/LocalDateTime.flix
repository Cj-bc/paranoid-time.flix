pub mod Time.LocalDateTime {
  use Time.Clock
  use Time.Duration
  use Time.TimeUnit

  /// Keeps time in milliseconds since the epoch
  pub enum LocalDateTime(Int64) with Eq, Order, Hash

  pub def now(): LocalDateTime \ Clock =
    LocalDateTime(Clock.now())

  pub def today(): LocalDateTime \ Clock =
    LocalDateTime(Clock.currentTime(TimeUnit.Days))

  pub def add(date: LocalDateTime, d: Duration): LocalDateTime =
    let LocalDateTime(t) = date;
    let Duration(d2) = d;
    LocalDateTime(t + d2)

  pub def sub(date: LocalDateTime, d: Duration): LocalDateTime =
    let LocalDateTime(t) = date;
    let Duration(d2) = d;
    LocalDateTime(t - d2)

  pub def between(d1: LocalDateTime, d2: LocalDateTime): Duration =
    let LocalDateTime(t1) = d1;
    let LocalDateTime(t2) = d2;
    Duration.Duration(Int64.abs(t1 - t2))
}
