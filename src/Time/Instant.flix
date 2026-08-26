pub mod Time.Instant {
  use Time.Clock
  use Time.Duration
  use Time.TimeUnit

  /// Keeps time in milliseconds since the epoch
  pub enum Instant(Int64) with Eq, Order, Hash

  pub def now(): Instant \ Clock =
    Instant(Clock.now())

  /// Returns Ok() when calculated Instant is in valud range, otherwise return the largest/smallest value.
  def internalTryAdd(t: Instant, d: Duration): Result[Int64, Instant] =
    let Instant(tms) = t;
    let dms = Duration.toMillis(d);
    if (dms < 0i64 and tms < (Int64.minValue() - dms)) Err(Int64.minValue())
    else
      if (0i64 < dms and (Int64.maxValue() - dms) < tms) Err(Int64.maxValue())
      else Ok(Instant(tms + dms))

  pub def tryAdd(t: Instant, d: Duration): Option[Instant] =
    internalTryAdd(t, d) |> Result.toOption

  pub def saturatingAdd(t: Instant, d: Duration): Instant =
    match internalTryAdd(t, d) {
      case Ok(v) => v
      case Err(v) => Instant(v)
    }

  pub def sub(date: Instant, d: Duration): Instant =
    let Instant(t) = date;
    Instant(t - Duration.toMillis(d))

  pub def between(d1: Instant, d2: Instant): Duration =
    let Instant(t1) = d1;
    let Instant(t2) = d2;
    Duration.Duration(Int64.abs(t1 - t2))
}
