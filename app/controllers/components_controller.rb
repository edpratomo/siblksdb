class ComponentsController < ApplicationController
  before_action :set_course, only: [:index_by_course]

  def index
  end

  def index_by_course
    @components = @course.components
    render json: @components
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
  end

  private
    def set_course
      @course = Course.find(params[:course_id])
    end

end
