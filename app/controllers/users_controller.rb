class UsersController < ApplicationController
  helper FriendshipsHelper

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
    @happy_count = @user.happy_things.count
    @words_for_wordcloud = WordAggregator.get_aggregated_words(@user, 40)
  end
end
