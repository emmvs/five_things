# frozen_string_literal: true

class CommentsController < ApplicationController # rubocop:disable Style/Documentation
  before_action :authenticate_user!
  before_action :set_happy_thing

  def create
    @comment = @happy_thing.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to happy_things_by_date_path(@happy_thing.start_time.strftime('%Y-%m-%d')),
                  notice: 'Comment added successfully!'
    else
      redirect_to happy_things_by_date_path(@happy_thing.start_time.strftime('%Y-%m-%d')),
                  alert: 'Failed to add comment.'
    end
  end

  private

  def set_happy_thing
    @happy_thing = HappyThing.find(params[:happy_thing_id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
