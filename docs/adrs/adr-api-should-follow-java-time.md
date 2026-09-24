# API name should be aligned with java.time as much as possible

## why? 

+ To reduce learning curve for other devs

I choose `java.time` instead of other libraries because: 

+ Higher possibilities that other devs are familiar with it because flix is JVM language. 
+ I've heard that java.time is well designed comparing to old java.util.Date.


## Exceptions

There are some exceptions for this decision. 

+ Append "try" prefix for methods that can raise exception. Use Either Option or Result instead of throwing exception. 
+ Create "saturating" version for functions that have valid range for its inputs(e.g. overflow/underflow.)

## other candidates

+ [C#: Noda Time](https://nodatime.org/)
+ [Rust: chrono](https://docs.rs/chrono/latest/chrono/index.html)
+ [JavaScript: Temporal](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Temporal)
+ [Haskell: time](https://hackage-content.haskell.org/package/time)
+ [Python: datetime](https://docs.python.org/3/library/datetime.html)
+ [Java: java.util.Date](https://docs.oracle.com/javase/jp/8/docs/api/java/util/Date.html)
+ [Go: time](https://pkg.go.dev/time)