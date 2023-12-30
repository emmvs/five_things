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

  private

  def happy_things_by_period(user, period)
    user.happy_things.where(start_time: period)
  end

  def clean_and_extract_words(text)
    words = text.downcase.gsub(/[^a-zA-Zäöüß0-9\s]/i, '').split
    stop_words = %w[
      als ab am aber an auf
      dem den
      ein eine einen einem es
      für
      ist in ins im mich mit nach
      von wie die der das dass
      ohne und um weil was
      zu zum
      the and but if or
      on as etc of else
      w to sth i
    ]
    words.reject { |word| stop_words.include?(word) }
  end
end