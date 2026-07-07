# frozen_string_literal: true

class CloseFriendsMailer < ApplicationMailer
  def confirmation(subscriber)
    @subscriber = subscriber
    @confirm_url = close_friends_confirm_url(
      token: CloseFriends::Token.generate(subscriber.id, CloseFriends::Token::CONFIRM)
    )
    mail(to: subscriber.email, subject: I18n.t('close_friends.mailer.confirmation_subject'))
  end

  def issue(subscriber, issue)
    @subscriber = subscriber
    @issue = issue
    @unsubscribe_url = close_friends_unsubscribe_url(
      token: CloseFriends::Token.generate(subscriber.id, CloseFriends::Token::UNSUBSCRIBE)
    )
    mail(to: subscriber.email,
         subject: I18n.t('close_friends.mailer.issue_subject', title: issue.title))
  end
end
