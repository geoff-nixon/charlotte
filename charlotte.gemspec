Gem::Specification.new do |s|
  s.name        = 'charlotte'
  s.version     = '0.1.1'
  s.licenses    = ['MIT']
  s.summary     = "Simple, pure Ruby character set encoding detector."
  s.description = "A simple (but fast!) character set encoding/binary detector and auto-converter for common encodings (UTF-8/16/32, ISO-8859-1, MacRoman, etc.). Extends String with String.detect_encoding, String.autoencode."
  s.authors     = ["Geoff Nixon"]
  s.email       = 'geoff@geoff.codes'
  s.files       = Dir['lib/*'] + Dir['bin/*'] + Dir['test/*']
  s.homepage    = 'https://github.com/geoff-codes/charlotte'
  s.required_ruby_version = '>= 1.9.3'
end
