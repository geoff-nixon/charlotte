Charlotte
=========

Ruby's "econv" (1.9.3+) implements native character set conversion functionality, but it lacks the ability to _detect_ encodings. This gem is a small, pure Ruby character set encoding detection library for quickly detecting and automatically converting to UTF-8.
The main thrust is to be lightweight and fast, rather that pedantic and exhaustive. It covers common encodings (UTF-8/16/32, ISO-8859-1, MacRoman, etc.), and returns rare legacy encodings and binary files as "ASCII-8BIT" / "BINARY", possibly for further processing if needed.
It was primarily written as a potential alternative to [charlock_holmes](https://github.com/brianmario/charlock_holmes) (used in [linguist](https:/github.com/github/linguist/)), which leverages the ICU library via a C++ extention, and [rchardet](https://github.com/jmhodges/rchardet), which, while exhaustive, is quite slow.

Pull requests, contributions, optimization, other ideas, greatly welcomed.

## Install
```sh
gem install charlotte
```
