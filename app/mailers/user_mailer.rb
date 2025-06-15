class UserMailer < ApplicationMailer
  def welcome(user)
    @user = user
    mail subject: "Welcome to artifacts!", to: user.email_address
  end
end
