module WordAggregator
  extend self

  def get_aggregated_words(user, word_limit)
    one_year_ago = Date.today - 1.year
    happy_things_of_last_year = happy_things_by_period(user, one_year_ago..Date.today)

    all_titles = happy_things_of_last_year.map(&:title).join(' ')
    words = clean_and_extract_words(all_titles)

    word_count = words.each_with_object(Hash.new(0)) { |word, counts| counts[word] += 1 }
    sorted_word_counts = word_count.sort_by { |_word, count| -count }
    sorted_word_counts.first(word_limit).to_h
  end

  def iterate_over_text_files(directory_path)
    Dir.glob("#{directory_path}/*.txt").map do |file_path|
      File.read(file_path)
    end
  end

  private

  def happy_things_by_period(user, period)
    user.happy_things.where(start_time: period)
  end

  def clean_and_extract_words(text)
    words = text.downcase.gsub(/[^a-zA-Zäöüß0-9\s]/i, '').split
    german_stop_words = load_stop_words(Rails.root.join('config', 'data', 'german_stopwords.txt'))
    english_stop_words = load_stop_words(Rails.root.join('config', 'data', 'english_stopwords.txt'))
    all_stop_words = german_stop_words + english_stop_words
    words.reject { |word| all_stop_words.include?(word) }
  end

  def load_stop_words(file_path)
    File.readlines(file_path).map(&:strip)
  end
end
