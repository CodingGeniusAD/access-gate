class AgeVerifier
  def initialize(user)
    @user = user
  end

  def call
    return nil unless @user.date_of_birth
    age = ((Time.zone.now - @user.date_of_birth.to_time) / 1.year).floor
    case age
    when 0..12
      :child
    when 13..17
      :teen
    else
      :adult
    end
  end
end 