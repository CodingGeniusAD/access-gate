class ConsentWorkflow
  def initialize(user)
    @user = user
  end

  def request_consent(parent_email)
    consent = AgeConsent.create!(user: @user, parent_email: parent_email, status: :pending)
    consent.regenerate_approval_token if consent.approval_token.blank?
    ConsentMailer.request_consent(consent).deliver_later
  end

  def approve(token)
    consent = AgeConsent.find_by(token: token)
    return false unless consent && consent.pending?
    consent.status = :approved
    consent.save!
    true
  end

  def reject(token)
    consent = AgeConsent.find_by(token: token)
    return false unless consent && consent.pending?
    consent.status = :rejected
    consent.save!
    true
  end
end
