require 'refined-refinements/core_exts'

describe RR::CoreExts do
  using RR::CoreExts

  describe 'String#sub' do
    context 'with a block' do
      it 'passes the match data as the first argument to the block' do
        was_called = false

        'Hello world!'.sub(/(?<word>[a-zA-Z]+)/) do |match, string_before_match, string_after_match|
          was_called = true

          expect(match).to be_kind_of(MatchData)
          expect(match[:word]).to eql('Hello')

          expect(string_before_match).to eql('')
          expect(string_after_match).to  eql(' world!')
        end

        expect(was_called).to be(true)
      end
    end
  end
end
