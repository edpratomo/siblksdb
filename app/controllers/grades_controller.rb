class GradesController < ApplicationController
  before_action :set_grade, only: [:show, :edit, :update, :update_component, :destroy]
  before_action :authorize_instructor, only: [:new, :create, :edit, :update, :update_component, :destroy, :edit_students, :update_students]
  before_action :set_instructor #, only: [:new, :create, :edit, :update, :destroy]

  filter_resource_access

  # GET /grades
  # GET /grades.json
  def index
    if @instructor
      @filterrific = initialize_filterrific(
        Grade,
        params_for_filterrific(@instructor),
        :select_options => {
          with_exam: @instructor.options_for_exam
        }
      ) or return

      @grades = Grade.filterrific_find(@filterrific).paginate(page: params[:page], per_page: 10)

      # for table heading
      @exam = Exam.find(params[:filterrific][:with_exam]) rescue nil

    else # for non-instructor viewer
      # if params[:instructor_id] 
      # else
      #redirect_to grades_url, notice: 'Grade was successfully destroyed.' }
    end
  end

  # GET /grades/1
  # GET /grades/1.json
  def show
  end

  # GET /grades/new
  def new
    # @grade = Grade.new
    @student_filterrific = initialize_filterrific(
        Student,
        params_for_student_filterrific(@instructor),
        :select_options => {
          with_pkg: @instructor.options_for_pkg # pkgs taught by this instructor
        }
    ) or return

    @students = Student.filterrific_find(@student_filterrific).paginate(page: params[:page], per_page: 10)
  end

  # GET /grades/1/edit
  def edit
  end

  # POST /grades
  # POST /grades.json
  def create
    @grade = Grade.new(grade_params)

    respond_to do |format|
      if @grade.save
        format.html { redirect_to @grade, notice: 'Grade was successfully created.' }
        format.json { render :show, status: :created, location: @grade }
      else
        format.html { render :new }
        format.json { render json: @grade.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_component
    component_id = params[:component_id]
    component_value = params[:component_value]

    respond_to do |format|
      current_grade = @grade.grade
      unless component_value =~ /^\d+$/
        format.html {
          render :text => (current_grade[component_id] || '-'),
                 :status => :unprocessable_entity
        }
      else
        if (current_grade[component_id] and current_grade[component_id] == component_value) or
           @grade.update({:grade => current_grade.merge({component_id => component_value})})
          format.html { render :text => component_value }
        else
          format.html {
            render :text => (current_grade[component_id] || '-'),
                   :status => :unprocessable_entity
          }
        end
      end
    end
  end

  # PATCH/PUT /grades/1
  # PATCH/PUT /grades/1.json
  def update
    respond_to do |format|
      if @grade.update(grade_params)
        format.html { redirect_to @grade, notice: 'Grade was successfully updated.' }
        format.json { render :show, status: :ok, location: @grade }
      else
        format.html { render :edit }
        format.json { render json: @grade.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /grades/1
  # DELETE /grades/1.json
  def destroy
    @grade.destroy
    respond_to do |format|
      format.html { redirect_to grades_url, notice: 'Grade was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_grade
      @grade = Grade.find(params[:id])
    end

    def set_instructor
      @instructor = current_user.instructor
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def grade_params
      params[:grade]
    end

    def params_for_filterrific instructor
      params[:filterrific] ||= {:with_exam => 0}
      params[:filterrific].tap do |e|
        e[:with_instructor] = instructor.id
      end
    end

    def params_for_student_filterrific instructor
      params[:filterrific] ||= {}
      params[:filterrific].tap do |e|
        e[:with_instructor] = instructor.id
      end
    end
end