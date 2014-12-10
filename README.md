Charlotte
=========

Ruby (1.9.3+) added "econv", native character set conversion functionality, but it lacks the ability to automatically detect encodings. This is why one
frequently sees errors regarding invalid byte sequences, etc.

This is a pure Ruby character set encoding detection library for detecting and automatically converting to UTF-8.

The main thrust is to be lightweight and fast, rather that pedantic and exhaustive. It covers common encodings (UTF-8/16/32, ISO-8859-1, MacRoman, etc.), and returns rare legacy encodings and binary files as "ASCII-8BIT", possibly for further processing if needed.

It was primarily written as a potential alternative to [charlock_holmes](https://github.com/brianmario/charlock_holmes) (used in [linguist](https:/github.com/github/linguist/), and other internal GitHub projects), which hoists the ICU library (~25MB) into memory in order leverage it for charset detection, and [rchardet](https://github.com/jmhodges/rchardet), which, while exhaustive, is quite slow (and LGPL).

Pull requests, contributions, optimization, other ideas, greatly welcomed!
