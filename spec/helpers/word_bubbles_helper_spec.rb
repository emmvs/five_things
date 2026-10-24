# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WordBubblesHelper, type: :helper do
  describe '#word_bubbles' do
    let(:words) do
      { 'coffee' => 142, 'friends' => 118, 'sun' => 97, 'walk' => 88, 'music' => 71, 'family' => 66,
        'lake' => 54, 'book' => 49, 'dinner' => 44, 'laugh' => 39, 'swim' => 33 }.to_a
    end
    let(:bubbles) { helper.word_bubbles(words) }

    it 'shows the ten most used words' do
      expect(bubbles.pluck(:word)).to eq(words.first(10).map(&:first))
    end

    it 'makes more used words bigger' do
      expect(bubbles.first[:radius]).to be > bubbles.last[:radius]
    end

    it 'keeps every ball inside the box' do
      bubbles.each do |bubble|
        expect(bubble[:center_x]).to be_between(bubble[:radius], 100 - bubble[:radius])
        expect(bubble[:center_y]).to be_between(bubble[:radius], 100 - bubble[:radius])
      end
    end

    it 'never overlaps two balls' do
      bubbles.combination(2).each do |first_bubble, second_bubble|
        distance = Math.hypot(first_bubble[:center_x] - second_bubble[:center_x],
                              first_bubble[:center_y] - second_bubble[:center_y])
        expect(distance).to be >= first_bubble[:radius] + second_bubble[:radius]
      end
    end

    it 'fits ten equally used words' do
      expect(helper.word_bubbles(('a'..'j').map { |word| [word, 5] }).size).to eq(10)
    end
  end
end
