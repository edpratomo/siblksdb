class ComponentsController < ApplicationController
  before_action :set_component, only: [:make_default, :show, :destroy]
  before_action :set_course, only: [:index_by_course]

  def index
  end

  def index_by_course
    @components = @course.components.to_a.inject([]) do |m,o|
      temp = o.as_json
      temp["created_at"] = temp["created_at"].strftime("%e %b %Y, %H:%M")
      temp["is_destroyable"] = o.is_destroyable?
      m << temp
      m
    end
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
    @component.destroy
    render json: @component
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
