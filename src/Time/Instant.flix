pub mod Time.Instant {
  use Time.Clock
  use Time.Duration
  use Time.TimeUnit

  pub enum Instant({
    /// stores seconds since Java Epoch (1970-01-01T00:00:00Z)
    secondsSinceEpoch: Int64,
    /// nano seconds. [0, 999_999_999]
    nano: Int32
  }) with Eq, Order, Hash

  pub def now(): Instant \ Clock =
    Instant({secondsSinceEpoch = clock.currentTime(TimeUnit.Seconds),
             nano = Int32.remainder(clock.currentTime(TimeUnit.NanoSeconds))})

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

  /// Returns Ok() when calculated Instant is in valud range, otherwise return the largest/smallest value.
  def internalTrySub(t: Instant, d: Duration): Result[Int64, Instant] =
    use Monad.{>>=};

    let Duration(dms) = d;
    if (dms == Int64.minValue()) {
      internalTryAdd(t, Duration(-(dms + 1i64))) >>= flip(internalTryAdd)(Duration.milliseconds(1))
    } else internalTryAdd(t, Duration(dms))

  pub def trySub(date: Instant, d: Duration): Option[Instant] =
    internalTrySub(date, d) |> Result.toOption

  pub def saturatingSub(t: Instant, d: Duration): Instant =
    match internalTrySub(t, d) {
      case Ok(v) => v
      case Err(v) => Instant(v)
    }

  pub def between(d1: Instant, d2: Instant): Option[Duration] =
    use Functor.{<$>};

    let Instant(t1) = d1;
    let Instant(t2) = d2;
    Duration.milliseconds <$> Int64.tryToInt32(Int64.abs(t1 - t2))
}
