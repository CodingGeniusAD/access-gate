class ContentFilter
  def initialize(user)
    @user = user
  end

  def filter(content)
    case @user.age_group
    when :child
      # Remove or mask adult/teen content
      content.gsub(/adult|teen/i, '[filtered]')
    when :teen
      # Remove or mask adult content
      content.gsub(/adult/i, '[filtered]')
    else
      content
    end
  end
end 