# frozen_string_literal: true

class EssenceMailer < ApplicationMailer
  def confirmation(subscriber)
    @subscriber = subscriber
    I18n.with_locale(subscriber.locale) do
      @confirm_url = the_essence_confirm_url(
        token: Essence::Token.generate(subscriber.id, Essence::Token::CONFIRM)
      )
      mail(to: subscriber.email, subject: I18n.t('essence.mailer.confirmation_subject'))
    end
  end
end
