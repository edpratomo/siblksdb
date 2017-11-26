class ComponentsController < ApplicationController
  before_action :set_component, only: [:make_default, :show]
  before_action :set_course, only: [:index_by_course]

  def index
  end

  def index_by_course
    @components = @course.components
    render json: @components
  end

  def make_default
    @component.is_default = true
    @component.save!
    render json: @component
  end

  def new
  end

  def create
  end

  def destroy
  end

  def edit
  end

  def show
    render :layout => false
  end

  private
    def set_component
      @component = Component.find(params[:id])
    end

    def set_course
      @course = Course.find(params[:course_id])
    end

end
