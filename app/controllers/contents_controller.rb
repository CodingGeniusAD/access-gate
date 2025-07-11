class ContentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_content, only: [ :show, :edit, :update, :destroy ]

  def index
    @contents = policy_scope(Content).recent
    @contents_by_age = {
      child: @contents.for_age_group(:child),
      teen: @contents.for_age_group(:teen),
      adult: @contents.for_age_group(:adult)
    }
  end

  def show
    authorize @content
  end

  def new
    @content = Content.new
    authorize @content
    @available_age_groups = available_age_groups_for_user
  end

  def create
    @content = Content.new(content_params)
    authorize @content

    # Additional validation to ensure user can create content for the selected age group
    unless policy(@content).can_create_for_age_group?(@content.age_group)
      @content.errors.add(:age_group, "you are not authorized to create content for this age group")
      @available_age_groups = available_age_groups_for_user
      render :new, status: :unprocessable_entity and return
    end

    if @content.save
      redirect_to @content, notice: "Content was successfully created."
    else
      @available_age_groups = available_age_groups_for_user
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @content
    @available_age_groups = available_age_groups_for_user
  end

  def update
    authorize @content

    # Additional validation to ensure user can update content for the selected age group
    unless policy(@content).can_create_for_age_group?(content_params[:age_group])
      @content.errors.add(:age_group, "you are not authorized to create content for this age group")
      @available_age_groups = available_age_groups_for_user
      render :edit, status: :unprocessable_entity and return
    end

    if @content.update(content_params)
      redirect_to @content, notice: "Content was successfully updated."
    else
      @available_age_groups = available_age_groups_for_user
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @content
    @content.destroy
    redirect_to contents_path, notice: "Content was successfully deleted."
  end

  private

  def set_content
    @content = Content.find(params[:id])
  end

  def content_params
    params.require(:content).permit(:title, :body, :content_type, :age_group)
  end

  def available_age_groups_for_user
    age_groups = []

    if policy(Content).can_create_for_age_group?(:child)
      age_groups << [ "👶 Child - Suitable for all ages", "child" ]
    end

    if policy(Content).can_create_for_age_group?(:teen)
      age_groups << [ "🧑‍🎓 Teen - Suitable for teens and adults", "teen" ]
    end

    if policy(Content).can_create_for_age_group?(:adult)
      age_groups << [ "👨‍💼 Adult - Adults only", "adult" ]
    end

    age_groups
  end
end
