# frozen_string_literal: true

module ThroughTheYearsHelper
  # Wraps the searched words in <mark>, but only at the start of a word, the same way the
  # search matches: searching "in" highlights "Instruments" but not the "in" inside "Trinidad".
  # Rails' highlight escapes the text, so it is safe to show.
  def years_highlight(text, query)
    words = query.to_s.scan(HappyThing::SEARCH_WORD).select { |word| word.length >= HappyThing::SEARCH_MIN_LENGTH }
    word_starts = words.map { |word| word_start_pattern(word) }
    highlight(text, word_starts, highlighter: '<mark class="years__mark">\1</mark>')
  end

  # For example "🦙 Lea · 24 October 2025 · Lisbon · Hobby".
  # The name only shows for friends' HappyThings, not for your own.
  def years_card_meta(happy_thing, query)
    details = [l(happy_thing.start_time.to_date, format: t('through_the_years.date_format')),
               *highlighted_place_and_category(happy_thing, query)]
    details.unshift(user_with_emoji(happy_thing.user)) unless happy_thing.user == current_user
    safe_join(details, ' · ')
  end

  # The current search and chosen chips, so every chip and "Show more" link keeps the others
  def years_filters(query:, year:, category:)
    { query: query.presence, year:, category: category&.id }
  end

  def years_filter_link(label, filters:, active:)
    link_to label, through_the_years_path(filters.compact),
            class: ['years__chip', { 'years__chip--active': active }],
            aria: { current: (active ? 'page' : nil) }
  end

  private

  def highlighted_place_and_category(happy_thing, query)
    [happy_thing.place, happy_thing.category&.name].compact_blank.map { |text| years_highlight(text, query) }
  end

  # Matches the word only where no letter or digit comes right before it, ignoring case
  def word_start_pattern(word)
    /(?<![\p{L}\p{N}])#{Regexp.escape(word)}/i
  end
end
