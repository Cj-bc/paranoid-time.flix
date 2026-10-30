pub mod Time.DayOfWeek {

  ///
  /// A day-of-week, such as Tuesday.
  ///
  /// The seven days follow ISO-8601, which starts the week on Monday: `Monday` has the
  /// value 1 and `Sunday` the value 7, and `Order` follows that same order.
  ///
  pub enum DayOfWeek with Eq, Order, Hash, ToString {
    case Monday
    case Tuesday
    case Wednesday
    case Thursday
    case Friday
    case Saturday
    case Sunday
  }

  ///
  /// Returns the `DayOfWeek` whose ISO-8601 value is `dayOfWeek`, from 1 (Monday) to
  /// 7 (Sunday), or `None` for any other value.
  ///
  pub def tryOf(dayOfWeek: Int32): Option[DayOfWeek] = match dayOfWeek {
    case 1 => Some(DayOfWeek.Monday)
    case 2 => Some(DayOfWeek.Tuesday)
    case 3 => Some(DayOfWeek.Wednesday)
    case 4 => Some(DayOfWeek.Thursday)
    case 5 => Some(DayOfWeek.Friday)
    case 6 => Some(DayOfWeek.Saturday)
    case 7 => Some(DayOfWeek.Sunday)
    case _ => None
  }

  /// Returns the ISO-8601 value of `d`, from 1 (Monday) to 7 (Sunday).
  pub def getValue(d: DayOfWeek): Int32 = match d {
    case DayOfWeek.Monday    => 1
    case DayOfWeek.Tuesday   => 2
    case DayOfWeek.Wednesday => 3
    case DayOfWeek.Thursday  => 4
    case DayOfWeek.Friday    => 5
    case DayOfWeek.Saturday  => 6
    case DayOfWeek.Sunday    => 7
  }

}
