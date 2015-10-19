class GradesController < ApplicationController
  before_action :set_grade, only: [:edit, :update, :destroy]
  before_action :set_exam_grade, only: [:show]
  before_action :authorize_instructor, only: [:new, :create, :edit, :update, :update_component, :destroy]
  before_action :set_instructor #, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_current_user

  # filter_resource_access
  filter_access_to :all, :except => :options_for_exam

  def options_for_exam
    @options = @instructor.options_for_exam(params[:id])
  end

  # complete grades
  def index_all
    if @instructor
      @filterrific = initialize_filterrific(
        Grade,
        params[:filterrific],
        :select_options => {
          sorted_by: Student.options_for_sorted_by,
          with_pkg: @instructor.options_for_pkg
        },
        default_filter_params: { sorted_by: 'students.name_asc', with_pkg: 0 }
      ) or return

      @grades = Grade.with_instructor(@instructor).joins(:student).
                filterrific_find(@filterrific).paginate(page: params[:page], per_page: 10)

    end
  end

  # GET /grades
  # GET /grades.json
  def index
    if @instructor
      @filterrific = initialize_filterrific(
        ExamGrade,
        params[:filterrific],
        :select_options => {
          with_exam: @instructor.options_for_exam
        },
        default_filter_params: { sorted_by: 'students.name_asc', with_exam: 0 }
      ) or return

      @exam_grades = ExamGrade.with_instructor(@instructor).joins(:student). #sorted_by("students.name_asc").
                     filterrific_find(@filterrific).paginate(page: params[:page], per_page: 10)

      # for table heading
      # @exam = Exam.find(params[:filterrific][:with_exam]) rescue nil
      @exam = Exam.find(@filterrific.to_hash.fetch("with_exam")) unless @exam_grades.empty?

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
    @grades = []
    @student_filterrific = initialize_filterrific(
        Student,
        params[:filterrific],
        :select_options => {
          sorted_by: Student.options_for_sorted_by,
          with_pkg: @instructor.options_for_pkg # pkgs taught by this instructor
        }
    ) or return

    @students = Student.with_instructor(@instructor).
                filterrific_find(@student_filterrific).
                sorted_by('name_asc'). # hard coded at the moment
                paginate(page: params[:page], per_page: 10)

    #store_location
  end

  # GET /grades/1/edit
  def edit
  end

  # POST /grades
  # POST /grades.json
  def create
    ActiveRecord::Base.transaction_user(@current_user) do
      exam = Exam.find(params[:exam_id])
      params[:student_ids].map do |student_id|
        students_record = StudentsRecord.find_by(pkg: exam.pkg, student: student_id, status: "active")
        if students_record
          grade = Grade.find_by(students_record: students_record)
          unless grade
            grade = Grade.new(students_record: students_record, instructor: @instructor)
            grade.save
          end
          exam_grade = ExamGrade.new(students_record: students_record, exam: exam, grade: grade)
          exam_grade.save
        end
      end
    end

    redirect_back_or_default(new_grade_url)
  end

  def update_component
    grade_id, component_id = params[:grade_component_id].split('_')
    component_value = params[:component_value]

    @grade = ExamGrade.find(grade_id)
    respond_to do |format|
      current_grade = @grade.exam_grade
      unless component_value =~ /^\d+(?:\.\d+)?$/
        format.html {
          render :text => (current_grade[component_id] || '-'),
                 :status => :unprocessable_entity
        }
      else
        if (current_grade[component_id] and current_grade[component_id] == component_value) or
           @grade.update({:exam_grade => current_grade.merge({component_id => component_value})})
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

    def set_exam_grade
      @exam_grade = ExamGrade.find(params[:id])
    end

    def set_instructor
      @instructor = current_user.instructor
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def grade_params
      params[:grade]
    end

    def set_current_user
      @current_user = current_user.username
    end
end
