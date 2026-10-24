# frozen_string_literal: true

# Full-text search over title, body and place in every language the app supports,
# plus pg_trgm for typo-tolerant matching
class AddSearchToHappyThings < ActiveRecord::Migration[8.0]
  SEARCH_CONFIGS = %w[simple english german swedish].freeze
  SEARCH_TEXT = "coalesce(title, '') || ' ' || coalesce(body, '') || ' ' || coalesce(place, '')"

  def change
    enable_extension 'pg_trgm'

    add_column :happy_things, :searchable, :virtual, type: :tsvector, stored: true, as: searchable_sql
    add_index :happy_things, :searchable, using: :gin
  end

  private

  def searchable_sql
    SEARCH_CONFIGS.map { |config| "to_tsvector('#{config}'::regconfig, #{SEARCH_TEXT})" }.join(' || ')
  end
end
