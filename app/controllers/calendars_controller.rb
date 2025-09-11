# frozen_string_literal: true

class CalendarsController < ApplicationController
  def show
    friend_ids = current_user.friends_and_friends_who_added_me_ids
    @user_ids = [current_user.id] + friend_ids

    @happy_things_of_you_and_friends = HappyThing.where(user_id: @user_ids).order(created_at: :desc)
  end
end
