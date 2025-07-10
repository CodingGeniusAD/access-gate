class AgeParticipationsController < ApplicationController
  before_action :authenticate_user!

  def show
    authorize :age_participation, :access?
    @content = ContentFilter.new(current_user).filter("This is adult and teen content.")
  end
end 