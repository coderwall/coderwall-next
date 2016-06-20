class UserMailer < ActionMailer::Base
  default from: "support@coderwall.com"

  def destroy_email(user)
    @user = user
    mail(to: 'support@coderwall.com', subject: "#{@user.username} deleted their account")
  end
end
