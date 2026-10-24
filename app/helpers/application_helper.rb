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

  # Lets a page be swiped right to go back, see swipe_back_controller.js
  def swipe_back_data
    {
      controller: 'swipe-back',
      action: 'touchstart->swipe-back#start touchmove->swipe-back#move touchend->swipe-back#end ' \
              'touchcancel->swipe-back#end turbo:before-cache@document->swipe-back#reset',
      swipe_back_fallback_url_value: root_path
    }
  end

  def nbsp
    raw('&nbsp;')
  end
end
