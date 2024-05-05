# frozen_string_literal: true

module UserRelated
  extend ActiveSupport::Concern

  included do
    helper_method :current_user_happy_things
  end

  private

  def current_user_happy_things
    current_user.happy_things
  end
end
