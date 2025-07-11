class ContentFilter
  def initialize(user)
    @user = user
  end

  def filter_text(text)
    case @user.age_group
    when :child
      # Remove or mask adult/teen content
      text.gsub(/adult|teen/i, "[filtered]")
    when :teen
      # Remove or mask adult content
      text.gsub(/adult/i, "[filtered]")
    else
      text
    end
  end

  def accessible_content
    Content.accessible_by(@user)
  end

  def content_for_age_group(age_group)
    Content.for_age_group(age_group)
  end

  def recommended_content
    # Return content appropriate for the user's age group
    case @user.age_group
    when :child
      Content.for_age_group(:child).recent.limit(5)
    when :teen
      Content.where("age_group IN (?)", [ Content::AGE_GROUPS[:child], Content::AGE_GROUPS[:teen] ]).recent.limit(5)
    when :adult
      Content.recent.limit(5)
    end
  end

  def content_summary
    {
      total_accessible: accessible_content.count,
      child_content: content_for_age_group(:child).count,
      teen_content: content_for_age_group(:teen).count,
      adult_content: content_for_age_group(:adult).count,
      user_age_group: @user.age_group,
      can_create_content: @user.adult? || @user.teen?
    }
  end
end
