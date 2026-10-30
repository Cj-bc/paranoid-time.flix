# Use "days since epoch" as internal representation for LocalDate type

`LocalDate` type represents a date without TimeZone nor Time information.

## Why?

Among several options I had, it had 

Used in [DotNet's System.DateOnly](https://github.com/dotnet/dotnet/blob/b0f34d51fccc69fd334253924abd8d6853fad7aa/src/runtime/src/libraries/System.Private.CoreLib/src/System/DateOnly.cs#L36-L40)

## Other candidates

### Holds year, month, days separately

```flix
// something like this:
pub enum LocalDate({ year = Int32, month = Int32, day = Int32 })
```

Holding year, month, day-of-month as separate field has some pros:

- Easy to construct
- Requires no conversion to retrive year, month, day-of-month data

However, It also has some downsides:

- We have to validate all fields when constructing it
  - e.g: year should be in range -9999 to 9999, month should be within 1-12, day-of-month's range is depends on month and year (because of leap year).
- As current flix (0.76.2) doesn't have any ability to hide constructor of publid types, we have to do that check evrey time to ensure invalid value is not given.

Especially, as

### Holds as nanoseconds/microseconds

As minimum resolution of `LocalDate` is "date", we do not need such high precision.
