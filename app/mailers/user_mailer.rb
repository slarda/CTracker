class UserMailer < ActionMailer::Base
  default from: CHAMPTRACKER_CONFIG[:mailer][:from]

  def to_new_member(user)
    @user = user
    mail(to: 'conharbis@champtracker.com', cc: 'nigel@greenshoresdigital.com', subject: "New profile registration: #{user.email}") # user.email
  end
end
