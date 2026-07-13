# frozen_string_literal: true

module ApplicationHelper
  def login_wave_emoji
    %w[👋🏻 👋🏼 👋🏽 👋🏾 👋🏿].sample
  end

  def user_with_emoji(user)
    content_tag(:span, class: 'user-with-emoji') do
      parts = []
      parts << user.emoji if user.emoji.present?
      parts << user.name
      safe_join(parts, nbsp)
    end
  end

  private

  def nbsp
    raw('&nbsp;')
  end
end
