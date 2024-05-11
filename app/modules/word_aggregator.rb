# frozen_string_literal: true

# The WordAggregator collects the most used words by the user within the last year
module WordAggregator
  extend self

  def aggregated_words(user, word_limit)
    texts = user_happy_things_texts(user)
    words = extract_significant_words(texts)
    sorted_word_counts(words, word_limit)
  end

  private

  def user_happy_things_texts(user)
    one_year_ago = Date.today - 1.year
    user.happy_things.where(start_time: one_year_ago..Date.today).pluck(:title).join(' ')
  end

  def extract_significant_words(texts)
    clean_words = texts.downcase.gsub(/[^a-zäöüß0-9\s]/i, '').split
    stop_words = load_stop_words
    clean_words.reject { |word| stop_words.include?(word) }
  end

  def sorted_word_counts(words, limit)
    words.each_with_object(Hash.new(0)) { |word, counts| counts[word] += 1 }
         .sort_by { |_word, count| -count }.first(limit).to_h
  end

  def load_stop_words
    german = File.readlines(Rails.root.join('config', 'data', 'german_stopwords.txt')).map(&:strip)
    english = File.readlines(Rails.root.join('config', 'data', 'english_stopwords.txt')).map(&:strip)
    german + english
  end
end
