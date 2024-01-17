class UserMailer < ApplicationMailer
  def happy_things_notification(user)
    @user = user
    mail(to: @user.email, subject: 'Happy Things incoming!🎁')
  end
end
