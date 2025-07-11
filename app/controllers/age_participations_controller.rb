class AgeParticipationsController < ApplicationController
  before_action :authenticate_user!

  def show
    authorize :age_participation, :access?
    @content_filter = ContentFilter.new(current_user)
    @content_summary = @content_filter.content_summary
    @recommended_content = @content_filter.recommended_content
    @accessible_content = @content_filter.accessible_content.limit(10)
  end
end
