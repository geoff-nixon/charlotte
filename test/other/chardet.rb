#!/usr/bin/env ruby
# Rough comparison using "charlock_holmes", which this is meant to replace.

require 'rchardet'
content = File.read(ARGF.argv[0])
detection = CharDet.detect(content)
puts detection
