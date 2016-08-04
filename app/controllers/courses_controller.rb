class CoursesController < ApplicationController
  before_action :set_course, only: [:show, :edit, :update, :destroy]
  before_action :set_current_user, only: [:update, :create, :destroy]
  before_action :set_max_level, only: [:show, :edit, :update]
  filter_resource_access

  # GET /courses
  # GET /courses.json
  def index
    @max_levels = Pkg.group(:course_id).maximum(:level)
    @courses = Course.all.reorder(:id)
  end

  # GET /courses/1
  # GET /courses/1.json
  def show
  end

  # GET /courses/new
  def new
    @course = Course.new
  end

  # GET /courses/1/edit
  def edit
  end

  # POST /courses
  # POST /courses.json
  def create
    @course = Course.new(course_params)

    respond_to do |format|
      if @course.save
        format.html { redirect_to @course, notice: 'Course was successfully created.' }
        format.json { render :show, status: :created, location: @course }
      else
        format.html { render :new }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /courses/1
  # PATCH/PUT /courses/1.json
  def update
    respond_to do |format|
      if ActiveRecord::Base.transaction_user(@current_user) {
        if params[:component]
          file_data = params[:component]
          if file_data.respond_to?(:read)
            yaml_content = file_data.read
          elsif file_data.respond_to?(:path)
            yaml_content = File.read(file_data.path)
          else
            logger.error "Bad file_data: #{file_data.class.name}: #{file_data.inspect}"
          end
          @component = Component.new(:content => yaml_content, :course => @course)
          @component.save!
        end
        @course.update(course_params)
      }
        format.html { redirect_to @course, notice: 'Course was successfully updated.' }
        format.json { render :show, status: :ok, location: @course }
      else
        format.html { render :edit }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /courses/1
  # DELETE /courses/1.json
  def destroy
    @course.destroy
    respond_to do |format|
      format.html { redirect_to courses_url, notice: 'Course was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_course
      @course = Course.find(params[:id])
    end

    def set_current_user
      @current_user = current_user.username
    end

    def set_max_level
      @max_level = Pkg.where(course: @course).maximum(:level)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def course_params
      #params[:course]
      params.require(:course).permit(:name, :program_id, :head_instructor_id, :idn_prefix)
    end
end
