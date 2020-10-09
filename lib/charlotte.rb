module Charlotte # (c) Geoff Nixon, 2014. MIT licence.
  #### Charlotte -- Fast and dirty encoding-or-binary detector/auto-converter.
  #### Pronounced "charlet"; rhymes with "chardet". Also, my kid sister's name!

  # Adapted from: https://github.com/file/file/blob/master/src/encoding.c:

  # T: Character appears in plain ASCII text.
  # I: Character appears in ISO-8859 text.
  # X: Character appears in extended ASCII text.
  # F: Character never appears in single-byte text.

  #####################################################
  ## \x00 #  F F F F F F F T T T T F T T F F  # \x0F ##
  ## \x10 #  F F F F F F F F F F F T F F F F  # \x1F ##
  ## \x20 #  T T T T T T T T T T T T T T T T  # \x2F ##
  ## \x30 #  T T T T T T T T T T T T T T T T  # \x3F ##
  ## \x40 #  T T T T T T T T T T T T T T T T  # \x4F ##
  ## \x50 #  T T T T T T T T T T T T T T T T  # \x5F ##
  ## \x60 #  T T T T T T T T T T T T T T T T  # \x6F ##
  ## \x70 #  T T T T T T T T T T T T T T T F  # \x7F ##
  ## \x80 #  X X X X X T X X X X X X X X X X  # \x8F ##
  ## \x90 #  X X X X X X X X X X X X X X X X  # \x9F ##
  ## \xA0 #  I I I I I I I I I I I I I I I I  # \xAF ##
  ## \xB0 #  I I I I I I I I I I I I I I I I  # \xBF ##
  ## \xC0 #  I I I I I I I I I I I I I I I I  # \xCF ##
  ## \xD0 #  I I I I I I I I I I I I I I I I  # \xDF ##
  ## \xE0 #  I I I I I I I I I I I I I I I I  # \xEF ##
  ## \xF0 #  I I I I I I I I I I I I I I I I  # \xFF ##
  #####################################################

  UTF8HASBOM = /^\xEF\xBB\xBF/n      #  [239, 187, 191]
  UTF32LEBOM = /^\xFF\xFE\x00\x00/n  # [255, 254, 0, 0]
  UTF32BEBOM = /^\x00\x00\xFE\xFF/n  # [0, 0, 254, 255]

  UTF16LEBOM = /^\xFF\xFE/n                # [255, 254]
  UTF16BEBOM = /^\xFE\xFF/n                # [254, 255]

  NOTIN1BYTE = /[\x00-\x06\x0B\x0E-\x1A\x1C-\x1F\x7F]/n
  NOTISO8859 = /[\x00-\x06\x0B\x0E-\x1A\x1C-\x1F\x7F\x80-\x84\x86-\x9F]/n

  # Information to identify MacRoman
  # https://stackoverflow.com/questions/4198804/
  # The bytes 0x81, 0x8D, 0x8F, 0x90, 0x9D are not used in windows-1252.
  # If they occur, then assume the data is MacRoman.
  NOTINCP1252 = /[\x81\x8D\x8F\x90\x9D]/n
  CP1252CHARS = /[\x92\x95\x96\x97\xAE\xB0\xB7\xE8\xE9\xF6]/n
  MCROMNCHARS = /[\x8E\x8F\x9A\xA1\xA5\xA8\xD0\xD1\xD5\xE1]/n

  # It is *much* faster simply to read into the "string" with regex than to
  # convert into a byte array/set: http://stackoverflow.com/a/27283992/2351351.

  def punch_encoding
    # The basic premise is just to quickly duck-punch encodings, branching
    # as early as possible on the most likely scenarios. Handles UTF-8/16/32,
    # ISO-8859-1, and other extented-ASCII encodings; long-tail, legacy
    # multibyte encodings are returned as ASCII-8BIT along with binary files.

    # detect and punch encoding
    detect_encoding(true)
  end

  def detect_encoding(punch=false)
    # use self or copy while detect
    detect = punch ? self : self[0..-1]

    detect.force_encoding('BINARY') # Needed to prevent non-matching regex charset.
    sample = detect[0..19]     # Keep sample string under 23 bytes.
    detect.sub!(UTF8HASBOM, '') if sample[UTF8HASBOM] # Strip any UTF-8 BOM.

    # See: http://www.daniellesucher.com/2013/07/23/ruby-case-versus-if/
    if    sample.ascii_only? && detect.force_encoding('UTF-8').valid_encoding?

    elsif sample[UTF32LEBOM] && detect.force_encoding('UTF-32LE').valid_encoding?
    elsif sample[UTF32BEBOM] && detect.force_encoding('UTF-32BE').valid_encoding?
    elsif sample[UTF16LEBOM] && detect.force_encoding('UTF-16LE').valid_encoding?
    elsif sample[UTF16BEBOM] && detect.force_encoding('UTF-16BE').valid_encoding?

    elsif detect.force_encoding('UTF-8').valid_encoding?

    elsif detect.force_encoding('BINARY')[NOTISO8859].nil?
      detect.force_encoding('ISO-8859-1')

    elsif detect.force_encoding('BINARY')[NOTIN1BYTE].nil?

      if  detect.force_encoding('BINARY')[NOTINCP1252].nil? &&
            detect.force_encoding('BINARY').scan(MCROMNCHARS).length < detect.force_encoding('BINARY').scan(CP1252CHARS).length

          detect.force_encoding('Windows-1252')
      else
          detect.force_encoding('MacRoman')
      end

    else  detect.force_encoding('BINARY')
    end

    detect.encoding
  end

  alias_method :detected_encoding, :detect_encoding

  def autoencode
    # TODO: Use Ruby 2.1 String#scrub if we're already UTF-8.
    # TODO: Use Ruby 2.2 Unicode normalization.

    unless detected_encoding == Encoding::BINARY
      self.encode!('UTF-8', invalid: :replace, undef: :replace,
                            replace: ' ').encode!(universal_newline: true)
    end
  end

  alias_method :autoencode!, :autoencode
  alias_method :detect_encoding!, :autoencode
end

class String
  include Charlotte
end
