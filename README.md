# paranoid-time.flix -- no-java dependent DateTime library for flix

This library provides very basic types and utilities for manipulating DateTime.
Requires no Java interop, thus no `unrestricted` security context is required.  
If you want more mature package, take a look at [stephentetley/flix-time](https://github.com/stephentetley/flix-time).

## Goal
- Create datetime library that can be used with `plain` or `paranoid` security context
- Provide basic functionality

## non-Goal

- As stable as Java's time library
- Provides as many functionalities as Java's time library

## Why new library instead of using flix-time?
There are already [stephentetley/flix-time](https://github.com/stephentetley/flix-time), which wraps Java's time library.
But as it uses Java interop internally, it is required to use `unrestricted` security context.  
I think it's safe to use it with `unrestricted` in this case because the author is known person, who actually is [flix contributor](https://github.com/flix/flix/commits?author=stephentetley), and all of its dependencies are written by himself.  
However, I believe it's good custom to reduce usage of `unrestricted` as much as possible. I think there should be some way to use DateTime with `paranoid` security context because Date and Time doesn't require any IO/casts by its nature when we can use `Clock` effect to retrieve them.
