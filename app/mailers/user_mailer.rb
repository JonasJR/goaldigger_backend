class UserMailer < ApplicationMailer
  default from: "Goaldigger.com"

  def send_recovery_password(email, new_password)
    @new_password = new_password
    mail(to: email, subject: "Your new password for Goaldigger!")
  end
end
