#!/usr/bin/env ruby
# Rough comparison using "charlock_holmes", which this is meant to replace.

require 'charlock_holmes'
require 'charlock_holmes/string'
content = File.read(ARGF.argv[0])
detection = CharlockHolmes::EncodingDetector.detect(content)
utf8_encoded_content = CharlockHolmes::Converter.convert content, detection[:encoding], 'UTF-8'
puts detection