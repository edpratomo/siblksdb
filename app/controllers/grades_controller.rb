class GradesController < ApplicationController
  before_action :set_grade, only: [:edit, :destroy, :options_for_exam_grade, :options_for_result]
  before_action :set_exam_grade, only: [:show]
  before_action :authorize_instructor, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_instructor #, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_current_user

  # filter_resource_access
  filter_access_to :all, :except => [:options_for_exam, :options_for_exam_grade]

  def options_for_exam
    @options = @instructor.options_for_exam(params[:id])
  end

  def options_for_exam_grade
    @options = @grade.options_for_exam_grade
  end

  def options_for_result
    @options = {'-':'- Pilih -','finished':'Lulus','failed':'Tidak Lulus'}
    current_status = @grade.students_record.status
    current_status = '-' unless @grade.result
    @options['selected'] = current_status
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

      @exam_grades = ExamGrade.with_instructor(@instructor). #joins(:student). #sorted_by("students.name_asc").
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
          if grade
            existing_exam_grade = ExamGrade.find_by(grade: grade)
            if existing_exam_grade
              # grade points to only one exam_grade:
              existing_exam_grade.grade = nil
              existing_exam_grade.save
            end
          else
            grade = Grade.new(students_record: students_record)
            grade.save
          end
          exam_grade = ExamGrade.new(students_record: students_record, exam: exam, grade: grade, instructor: @instructor)
          exam_grade.save
        end
      end
    end

    redirect_back_or_default(new_grade_url)
  end

  # PATCH/PUT /grades/1
  # PATCH/PUT /grades/1.json
  def update # proxy method
    grade_type = params[:type]
    unless grade_type
      render text: "Grade type not given", status: :unprocessable_entity
      return
    end

    case grade_type
    when "exam"
      update_exam_grade
    when "theory"
      update_theory_grade
    when "anypkg"
      update_anypkg_grade
    when "pkg"
      update_pkg_grade
    when "exam_ref"
      update_exam_ref
    when "theory_ref"
      update_theory_ref
    when "result"
      update_result
    else
      render text: "Unknown grade type: #{grade_type}", status: :unprocessable_entity
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
      @grade = Grade.find(params[:id].split('_').first)
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

    # the following methods are invoked via the update method which is called by jeditable:
    # update_exam_grade
    # update_theory_grade
    # update_anypkg_grade
    # update_pkg_grade
    # update_exam_ref
    # update_theory_ref

    def update_anypkg_grade
      grade_id, component_id = params[:grade_component_id].split('_')
      component_value = params[:component_value]

      @grade = Grade.find(grade_id)
      respond_to do |format|
        current_grade = @grade.anypkg_grade
        #unless component_value =~ /^\d+(?:\.\d+)?$/
        #  format.html {
        #    render :text => (current_grade[component_id] || '-'),
        #           :status => :unprocessable_entity
        #  }
        #else
          if (current_grade[component_id] and current_grade[component_id] == component_value) or
             @grade.update({:anypkg_grade => current_grade.merge({component_id => component_value})})
            format.html { render :text => component_value }
          else
            format.html {
              render :text => (current_grade[component_id] || '-'),
                     :status => :unprocessable_entity
            }
          end
        #end
      end
    end

    def update_theory_grade
      grade_id = params[:id].split('_').first
      values = params[:value].split(' ')
      grade = Grade.find(grade_id)
      @theory_grades = grade.theory_grades
      [0, 1].each do |idx|
        unless @theory_grades[idx]
          if values[idx]
            @theory_grades[idx] = TheoryGrade.new(students_record: grade.students_record,
                                                  student: grade.student, grade_sum: values[idx])
            @theory_grades[idx].save
          end
        else
          if values[idx]
            @theory_grades[idx].update({grade_sum: values[idx]})
          else
            @theory_grades[idx].delete
          end
        end
      end
      # pick the best value
      if values[1] and values[1] > values[0]
        grade.theory_grade = @theory_grades[1]
        grade.save
      else
        grade.theory_grade = @theory_grades[0]
        grade.save
      end

      #render text: grade.theory_grade.grade_sum
      render :show_theory_grade, layout: false
    end

    def update_exam_grade
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

    def update_exam_ref
      grade_id = params[:id].split('_').first
      exam_grade = ExamGrade.find(params[:value])
      @grade = Grade.find(grade_id)
      if @grade.update(exam_grade: exam_grade)
        render text: exam_grade.grade_sum # show new value
      else
        render text: @grade.exam_grade.grade_sum, status: :unprocessable_entity
      end
    end

    def update_result
      grade_id = params[:id].split('_').first
      @grade = Grade.find(grade_id)
      if @grade.set_result(params[:value], @current_user)
        render text: t(params[:value])
      else
        render text: '-', status: :unprocessable_entity
      end
    end
end
