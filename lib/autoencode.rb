#!/usr/bin/env ruby                                           # 'autoencode' - Geoff Nixon, 2014
require 'set'            # Fast, dirty, pure-Ruby encoding-or-binary detector and auto-converter.

### Please help! There is (or will be) a list of things that need doing on Github, ###
### but number one TODO is to actually make this a library with a client script.   ###

### Instead of this horrible nonsense I've hacked together.


# Some thoughts on library (maybe?):
# - String.autoencoding       #=> Returns dectected encoding, regarless of "declared" encoding.
# - String.sane_encoding?     #=> true if valid string and  encoding matches "declared" encoding.
# - String.autoencode         #=> Regularize a string to valid UTF-8. If invalid text, returns nil?
# - String.autoencode!        #=> Regularize a string to valid UTF-8. If invalid text, returns nil .
# - String.string?            #=> True if string is not garbage (i.e., binary).
# - String.binary?



### Ugly shims I put in in 10 seconds to demo functionality as utility. ###

if ARGF.argv[0] == '-v'; file = ARGF.argv[1]; else file = ARGF.argv[0] end

def readin(file, encoding); File.binread(file).force_encoding(encoding) end


# Characters which never appear in valid single-byte text encodings. See table below.

bad_bytes = Set[0,1,2,3,4,5,6,11,14,15,16,17,18,19,20,21,22,23,24,25,26,28,29,30,31,127]
# TODO: See if http://stackoverflow.com/a/27249124/2351351 is faster.

## 'bad_bytes' borrowed from https://github.com/file/file/blob/master/src/encoding.c, i.e.,

##  F  /* character never appears in text */
##  T  /* character appears in plain ASCII text */
##  I  /* character appears in ISO-8859 text */
##  X  /* character appears in non-ISO extended ASCII (Mac, IBM PC) */
##
##    F, F, F, F, F, F, F, T, T, T, T, F, T, T, F, F,  /* 0x0X */
##    F, F, F, F, F, F, F, F, F, F, F, T, F, F, F, F,  /* 0x1X */
##    T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T,  /* 0x2X */
##    T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T,  /* 0x3X */
##    T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T,  /* 0x4X */
##    T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T,  /* 0x5X */
##    T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T,  /* 0x6X */
##    T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, F,  /* 0x7X */
##    X, X, X, X, X, T, X, X, X, X, X, X, X, X, X, X,  /* 0x8X */
##    X, X, X, X, X, X, X, X, X, X, X, X, X, X, X, X,  /* 0x9X */
##    I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I,  /* 0xaX */
##    I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I,  /* 0xbX */
##    I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I,  /* 0xcX */
##    I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I,  /* 0xdX */
##    I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I,  /* 0xeX */
##    I, I, I, I, I, I, I, I, I, I, I, I, I, I, I, I   /* 0xfX */

# This generally follows that philosophy, except that (currently), all legacy single-byte encodings
# like ISO-8859-1 (and other similar encoding which are not easily distinguished, like MacRoman) are
# converted as Windows-1252 per the HTML standard: http://encoding.spec.whatwg.org/#names-and-labels

# We can rule out many binary files, and "rule in" some encodings with a short sample string.
# In the first block, the sample will either indicates an ASCII-ish encoding, or branch to rescue.

sample = File.binread(file, 20)
# http://patshaughnessy.net/2012/1/4/never-create-ruby-strings-longer-than-23-characters

# I read somewhere that if..elsif is faster than case statements in Ruby. The branching could
# be a whole lot better, but it works ok.
if sample.nil?
  encoding = 'EMPTY'
else
  sample.force_encoding('UTF-8')

  begin
    sample_codepoints = sample.codepoints

    if sample.ascii_only?
      data = readin(file, 'UTF-8')
    elsif sample.valid_encoding? # Remove UTF-8 BOM.
      data = readin(file, 'UTF-8').sub!(/^\xEF\xBB\xBF/, '') if sample_codepoints[0] == 65279
    end

    if data.valid_encoding?
      encoding = data.encoding.to_s
    elsif Set.new(data.bytes).disjoint? bad_bytes
      data.force_encoding('ISO-8859-1') # We call it ISO...
      encoding = data.encoding.to_s
      data.force_encoding('Windows-1252') # But we actually convert as Windows-1252.
    else
      encoding = 'BINARY'; encoding = data.encoding.to_s # Maybe a gzexe or something like that.
    end

  rescue # Our sample is not valid ASCII/UTF-8 sequence.
    sample_bytes = sample.bytes

    if    sample.bytes[0..3] == [255, 254, 0, 0]
      data = readin(file, 'UTF-32LE')
    elsif sample.bytes[0..1] == [255, 254]
      data = readin(file, 'UTF-16LE')
    elsif sample.bytes[0..1] == [254, 255]
      data = readin(file, 'UTF-16BE')
    elsif sample.bytes[0..3] == [0, 0, 254, 255]
      data = readin(file, 'UTF-32BE')
    elsif Set.new(sample.bytes).disjoint? bad_bytes
      data = readin(file, 'ISO-8859-1')
      if  Set.new(data.bytes).disjoint? bad_bytes
        data.force_encoding('ISO-8859-1')
        encoding = data.encoding.to_s
        data.force_encoding('Windows-1252')
      end
    else
      encoding = 'BINARY' # Maybe a gzexe or something.
    end
    encoding ||= data.encoding.to_s
  end
  if encoding != 'BINARY'
    begin
      data.encode!('UTF-8', :universal_newline => true)
      puts data + "\n\n" if ARGF.argv[0] == '-v'
      STDERR.puts "\n\tFilename: " + file
      STDERR.puts "\tEncoding: "+encoding+', 1:1 conversion to '+data.encoding.to_s+".\n\n"
    rescue
      data.encode!('UTF-8', :invalid => :replace, :undef => :replace, :universal_newline => true)
      puts data + "\n\n" if ARGF.argv[0] == '-v'
      STDERR.puts "\n\tFilename: " + file 
      STDERR.puts "\tEncoding : "+encoding+', lossy conversion to '+data.encoding.to_s+".\n\n"
    end
  else
   STDERR.puts "\n\tFilename: " + file
   STDERR.puts "\tBinary detected.\n\n"
  end
end