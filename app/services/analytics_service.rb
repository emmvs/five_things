# frozen_string_literal: true

# Analytics service for aggregated, anonymized user insights
# GDPR-compliant: No individual user data is exposed
class AnalyticsService
  MINIMUM_USER_THRESHOLD = 10 # K-anonymity: require at least 10 users for any stat

  class << self
    # Global word frequency across all users
    # Returns only if enough users contribute to prevent identification
    def global_word_trends(limit: 50)
      total_users = User.count
      return [] if total_users < MINIMUM_USER_THRESHOLD

      # Aggregate words from all users
      all_words = User.includes(:happy_things).flat_map do |user|
        WordAggregator.aggregated_words(user, limit)
      end

      # Group and count, return top N
      word_counts = all_words.group_by { |w| w[:text] }
                             .transform_values(&:count)
                             .sort_by { |_, count| -count }
                             .first(limit)
                             .to_h

      {
        total_users_contributing: total_users,
        word_trends: word_counts,
        generated_at: Time.current
      }
    end

    # Most popular categories (anonymized)
    def popular_categories
      total_things = HappyThing.count
      return [] if User.count < MINIMUM_USER_THRESHOLD

      Category.joins(:happy_things)
              .group('categories.name')
              .select('categories.name, COUNT(happy_things.id) as usage_count')
              .order('usage_count DESC')
              .limit(10)
              .map { |c| { category: c.name, percentage: (c.usage_count.to_f / total_things * 100).round(1) } }
    end

    # Peak happiness hours (when do people log happy things?)
    def peak_happiness_hours
      return [] if User.count < MINIMUM_USER_THRESHOLD

      HappyThing.where.not(start_time: nil)
                .group('EXTRACT(HOUR FROM start_time)')
                .count
                .sort_by { |hour, _| hour }
                .map { |hour, count| { hour: hour.to_i, count: } }
    end

    # Average happy things per day (anonymized)
    def community_happiness_trends(days: 30)
      return [] if User.count < MINIMUM_USER_THRESHOLD

      start_date = days.days.ago.to_date

      HappyThing.where('start_time >= ?', start_date)
                .group('DATE(start_time)')
                .count
                .sort_by { |date, _| date }
                .map do |date, count|
                  {
                    date:,
                    average_per_user: (count.to_f / User.count).round(2)
                  }
                end
    end

    # Top locations (anonymized, city level only)
    def popular_locations(limit: 20)
      return [] if User.count < MINIMUM_USER_THRESHOLD

      HappyThing.where.not(place: nil)
                .group(:place)
                .count
                .sort_by { |_, count| -count }
                .first(limit)
                .select { |_, count| count >= 5 } # Only show places mentioned 5+ times
                .map { |place, count| { location: place, mentions: count } }
    end

    # Friendship network stats (anonymized)
    def friendship_stats
      return {} if User.count < MINIMUM_USER_THRESHOLD

      total_friendships = Friendship.where(accepted: true).count / 2 # Bidirectional

      {
        total_users: User.count,
        total_friendships:,
        average_friends_per_user: (total_friendships.to_f * 2 / User.count).round(1),
        users_with_friends: User.joins(:friendships).where(friendships: { accepted: true }).distinct.count
      }
    end

    # Activity levels (anonymized distribution)
    def user_engagement_distribution
      return [] if User.count < MINIMUM_USER_THRESHOLD

      # Group users by activity level without exposing individuals
      counts = User.left_joins(:happy_things)
                   .group('users.id')
                   .select('users.id, COUNT(happy_things.id) as thing_count')
                   .map(&:thing_count)

      {
        very_active: counts.count { |c| c >= 50 },
        active: counts.count { |c| c >= 20 && c < 50 },
        moderate: counts.count { |c| c >= 5 && c < 20 },
        new_users: counts.count { |c| c < 5 }
      }
    end

    # Check if we have enough users for analytics
    def analytics_available?
      User.count >= MINIMUM_USER_THRESHOLD
    end

    # Get all community insights in one call
    def community_insights
      unless analytics_available?
        return { available: false,
                 reason: "Minimum #{MINIMUM_USER_THRESHOLD} users required" }
      end

      {
        available: true,
        word_trends: global_word_trends(limit: 30),
        categories: popular_categories,
        peak_hours: peak_happiness_hours,
        happiness_trends: community_happiness_trends(days: 30),
        locations: popular_locations(limit: 15),
        friendships: friendship_stats,
        engagement: user_engagement_distribution,
        generated_at: Time.current
      }
    rescue StandardError => e
      Rails.logger.error("Analytics generation failed: #{e.message}")
      { available: false, error: 'Analytics temporarily unavailable' }
    end
  end
end
