# frozen_string_literal: true

RSpec.describe Spellr::Wordlist do
  subject { described_class.new('$PROJECT/wordlist') }

  around { |e| with_temp_dir { e.run } }

  describe '#include?' do
    before do
      stub_fs_file 'wordlist', <<~WORDLIST
        bar
        foo
      WORDLIST
    end

    it 'includes words even when cached' do
      expect(subject).to include 'bar'
      expect(subject).to include 'bar'
    end

    it 'excludes words even when cached' do
      expect(subject).not_to include 'baz'
      expect(subject).not_to include 'baz'
    end

    it 'includes words even with case differences' do
      expect(subject).to include 'BAR'
      expect(subject).to include 'BAR'
    end

    it 'excludes words even with case differences' do
      expect(subject).not_to include 'BAZ'
      expect(subject).not_to include 'BAZ'
    end
  end
end
