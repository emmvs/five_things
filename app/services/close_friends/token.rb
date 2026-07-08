# frozen_string_literal: true

module CloseFriends
  module Token
    CONFIRM = 'confirm'
    UNSUBSCRIBE = 'unsubscribe'
    EXPIRY = 7.days

    module_function

    def generate(subscriber_id, purpose)
      verifier.generate([subscriber_id, purpose], expires_in: EXPIRY)
    end

    def verify(token, purpose)
      subscriber_id, token_purpose = verifier.verify(token)
      return nil unless token_purpose == purpose

      CloseFriendsSubscriber.find_by(id: subscriber_id)
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      nil
    end

    def verifier
      Rails.application.message_verifier('close_friends_tokens')
    end
  end
end
