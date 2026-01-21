# frozen_string_literal: true

class ReactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_happy_thing

  def create
    @reaction = @happy_thing.reactions.find_by(user: current_user)

    if @reaction
      # Reaction exists, delete it (toggle off)
      @reaction.destroy
      render json: {
        success: true,
        deleted: true,
        reaction_count: @happy_thing.reactions.count
      }, status: :ok
    else
      # Create new reaction (toggle on)
      @reaction = @happy_thing.reactions.build(user: current_user, emoji: params[:emoji] || '❤️')

      if @reaction.save
        render json: {
          success: true,
          deleted: false,
          reaction: {
            id: @reaction.id,
            emoji: @reaction.emoji,
            user_id: @reaction.user_id
          },
          reaction_count: @happy_thing.reactions.count
        }, status: :created
      else
        render json: {
          success: false,
          errors: @reaction.errors.full_messages
        }, status: :unprocessable_entity
      end
    end
  end

  private

  def set_happy_thing
    @happy_thing = HappyThing.find(params[:happy_thing_id])
  end
end
