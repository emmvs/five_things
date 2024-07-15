# frozen_string_literal: true

RSpec.describe PoetryService, type: :service do
  describe '#call' do
    context 'when real poem is available' do
      it 'returns a real poem' do
        allow(PoetryService).to receive(:random_poem).and_return('Real Poem')
        service = PoetryService.new
        expect(service.call).to eq('Real Poem')
      end
    end

    context 'when real poem is not available' do
      it 'returns a fake poem' do
        allow(PoetryService).to receive(:random_poem).and_return(nil)
        expect(PoetryService.new.call).to include(:title, :author, :lines)
      end
    end

    context 'when JSON parsing fails' do
      it 'handles JSON::ParserError and returns nil' do
        allow(PoetryService).to receive(:random_poem).and_raise(JSON::ParserError.new('unexpected token'))

        expect { PoetryService.new.call }.not_to raise_error
      end
    end
  end
end
