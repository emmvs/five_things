# frozen_string_literal: true

module CalendarHelper
  MAX_CALENDAR_EMOJIS = 4

  # The month the calendar shows, from the ?start_date=2026-10-01 the arrows link to.
  # Anything else in the URL, even a very long string, falls back to today.
  def calendar_month
    Date.iso8601(params[:start_date].to_s)
  rescue ArgumentError
    Date.current
  end

  def calendar_users_by_day(happy_things, user_ids, month)
    happy_things.where(start_time: month.in_time_zone.all_month)
                .includes(:user)
                .group_by { |happy_thing| happy_thing.start_time.to_date }
                .transform_values { |day_things| sorted_calendar_users(day_things, user_ids) }
  end

  def calendar_day_label(date, users)
    "#{l(date, format: t('calendar.day_heading'))}, #{t('calendar.people', count: users.size)}"
  end

  private

  def sorted_calendar_users(happy_things, user_ids)
    happy_things.map(&:user).uniq.sort_by { |user| user_ids.index(user.id) || user_ids.size }
  end
end
