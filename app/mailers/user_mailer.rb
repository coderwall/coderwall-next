class UserMailer < ActionMailer::Base
  default from: "support@coderwall.com"

  def destroy_email(user)
    @user = user
    mail(to: 'support@coderwall.com', subject: "#{@user.username} deleted their account")
  end

  def partnership_expired(user)
    @user = user
    mail(to: user.partner_email, bcc: 'support@coderwall.com', subject: "Important Partner update on Coderwall")
  end

end
