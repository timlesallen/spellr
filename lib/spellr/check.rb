# frozen_string_literal: true

require 'in_threads'
module Spellr
  class Check
    attr_reader :exit_code
    attr_reader :files, :reporter

    def initialize(files: [], reporter: Spellr.config.reporter)
      @files = files
      @reporter = reporter
      @exit_code = 0
    end

    def check
      files.in_threads.map do |file|
        file.each_line do |line, line_number|
          line.each_token do |token, startpos|
            next if check_token(token, file.dictionaries)

            reporter.call(token, startpos, line, line_number, file)
            @exit_code = 1
          end
        end
      end
    end

    private

    def check_token(token, dictionaries)
      return true if dictionaries.any? { |d| d.include?(token) }

      # TODO: this needs work
      # return false unless Spellr.config.run_together_words?

      # return false if token.length > Spellr.config.run_together_words_maximum_length

      # token.subwords.any? do |subword_set|
      #   subword_set.all? do |subword|
      #     subword_string = subword.to_s.downcase + "\n"
      #     dictionaries.any? { |d| d.bsearch { |value| subword_string <=> value } }
      #   end
      # end
    end
  end
end
