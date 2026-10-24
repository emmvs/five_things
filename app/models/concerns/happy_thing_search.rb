# frozen_string_literal: true

# Search for the Through the years page. See the AddSearchToHappyThings migration
# for the searchable column and the pg_trgm extension this relies on.
module HappyThingSearch
  extend ActiveSupport::Concern

  SEARCH_MIN_LENGTH = 2
  # Longer searches are cut off, so nobody can send a huge query to the database
  SEARCH_MAX_LENGTH = 100
  # A word is a run of letters or digits: "sunny, lisb!" has the words "sunny" and "lisb"
  SEARCH_WORD = /[\p{L}\p{N}]+/
  # Typo matching only kicks in for one single word of at least this many letters,
  # shorter or longer searches would match too much
  TYPO_MIN_LENGTH = 4
  # How similar a title or place has to be to count as a typo match, from 0 (anything) to 1 (identical)
  TYPO_SIMILARITY = 0.55

  # Finds HappyThings that match in any of three ways:
  #   1. Full text: words in the title, body or place, including other word forms
  #      ("surfed" finds "surfing") and unfinished words ("lisb" finds "Lisbon").
  #      Checked in all four languages of the searchable column, see the AddSearchToHappyThings migration.
  #   2. Typos: a title or place close to a single search word ("lisbn" finds "Lisbon")
  #   3. Category: the category name contains the search ("hob" finds "Hobby")
  # The search itself only goes in through the :named values, never into the SQL text.
  SEARCH_SQL = <<~SQL.squish
    happy_things.searchable @@ to_tsquery('simple', :full_text_query)
    OR happy_things.searchable @@ to_tsquery('english', :full_text_query)
    OR happy_things.searchable @@ to_tsquery('german', :full_text_query)
    OR happy_things.searchable @@ to_tsquery('swedish', :full_text_query)
    OR (:typo AND (word_similarity(:query, coalesce(happy_things.title, '')) >= :similarity
                   OR word_similarity(:query, coalesce(happy_things.place, '')) >= :similarity))
    OR categories.name ILIKE :category_pattern
  SQL

  included do
    scope :search, lambda { |query|
      left_joins(:category).where(
        SEARCH_SQL,
        query:,
        full_text_query: full_text_query(query),
        category_pattern: "%#{sanitize_sql_like(query)}%",
        typo: typo_search?(query),
        similarity: TYPO_SIMILARITY
      )
    }
  end

  class_methods do
    # "sunny lisb" becomes "sunny:* & lisb:*": every word has to match, and ":*" also
    # matches longer words that start with it
    def full_text_query(query)
      query.scan(SEARCH_WORD).map { |word| "#{word}:*" }.join(' & ')
    end

    def typo_search?(query)
      single_word = query.scan(SEARCH_WORD) == [query]
      single_word && query.length >= TYPO_MIN_LENGTH
    end
  end
end
