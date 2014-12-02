autoencode
==========

Ruby's (1.9.3+) "econv" charset conversion is great — but it lacks the ability to automatically detect and properly encode.
This is a first go at a utility/library for doing this, in pure Ruby. The idea is to be lightweight and fast, rather that pendantic and slow, even if it means sacrificing a little bit of accuracy.

Presently, GitHub's [linguist](github/linguist) uses [charlock_holmes](brian_mario/charlock_holmes) to do this, which hoists the entire ICU library (~25MB) into memory in order to do this same thing.
My initial (probably very poor) benchmarks seem to indicate that this is ±2.5 times faster than charlock at this task.

Pull requests, contributions, optimization, other ideas, greatly welcomed!
