# frozen_string_literal: true

require 'set'
require 'strscan'
module Spellr
  class Tokenizer < StringScanner
    def tokenize
      tokens = []
      each do |token, _start, _end|
        tokens << token
      end
      tokens
    end

    def each
      until eos?
        start, t = next_token
        next unless t
        next if t.length < Spellr.config.word_minimum_length

        yield t, start
      end
      reset
    end

    def next_token
      skip(%r{[^[:alpha:]/#0-9]+})
      skip(/[\n\r]+/)
      skip_url
      skip_hex
      skip_email
      skip(%r{[/#0-9]+})
      [charpos, title_case || lower_case || upper_case]
    end

    def title_case
      scan(/[[:upper:]][[:lower:]]+(?:'[[:lower:]]+(?<!s))*/)
    end

    def lower_case
      scan(/[[:lower:]]+(?:'[[:lower:]]+(?<!s))*/)
    end

    def upper_case
      scan(/[[:upper:]]+(?:'[[:upper:]]+(?<!S))*(?![[:lower:]])/)
    end

    def skip_url
      skip(%r{(?://|https?://|s?ftp://|file:///|mailto:)[[:alnum:]%&.@+=/?#_-]+})
    end

    def skip_email
      skip(/[[:alnum:]._-]+@[[:alnum:]._-]+/)
    end

    def skip_hex
      skip(/(?:#|0x)(?:\h{6}|\h{3})/)
    end
  end
end
