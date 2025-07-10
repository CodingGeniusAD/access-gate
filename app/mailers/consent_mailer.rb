class ConsentMailer < ApplicationMailer
  def request_consent(age_consent)
    @age_consent = age_consent
    @user = age_consent.user
    @approve_url = approve_age_consent_url(token: age_consent.approval_token)
    @deny_url = deny_age_consent_url(token: age_consent.approval_token)
    mail(to: age_consent.parent_email, subject: 'Parental Consent Request for AccessGate')
  end
end
