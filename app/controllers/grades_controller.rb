class GradesController < ApplicationController
  before_action :set_grade, only: [:show, :edit, :update, :destroy]
  before_action :set_students_record, only: [:new]
  before_action :set_current_user, only: [:update, :create, :destroy]
  before_action :set_component, only: [:show_by_component]
  before_action :set_instructor
  after_action :generate_cert, only: [:update, :create]
#  filter_resource_access
  filter_access_to :update, :attribute_check => true

  class ComponentNotFound < StandardError
  end

  rescue_from ComponentNotFound, :with => :component_not_found

  def component_not_found(exception)
    flash[:notice] = "Belum ada komponen nilai untuk kursus ini."
    redirect_to grades_path
  end

  # GET /grades
  # GET /grades.json
  def index
    if @instructor
      @filterrific = initialize_filterrific(
        StudentsRecord,
        params[:filterrific],
        :select_options => {
          sorted_by: StudentsRecord.options_for_sorted_by,
          with_pkg: @instructor.options_for_pkg,
          with_status: Grade.options_for_student_status
        },
        default_filter_params: { sorted_by: 'started_on_asc' }
      ) or return

      @students_records = if @filterrific.to_hash["with_status"] != "active"
        StudentsRecord.with_grade_instructor(@instructor).
                       filterrific_find(@filterrific).paginate(page: params[:page], per_page: 10)
      else
        StudentsRecord.with_instructor(@instructor).
                       filterrific_find(@filterrific).paginate(page: params[:page], per_page: 10)
      end
    else # staff login
      @filterrific = initialize_filterrific(
        Grade,
        params[:filterrific],
        :select_options => {
          sorted_by: Grade.options_for_sorted_by,
          with_pkg: Grade.options_for_pkg,
          with_instructor: Grade.options_for_instructor,
          with_student_status: Grade.options_for_student_status
        },
        default_filter_params: { sorted_by: 'started_on_asc' }
      ) or return

      @grades = Grade.filterrific_find(@filterrific).paginate(page: params[:page], per_page: 10)

      render :index_staff
    end
  end

  # GET /grades/1
  # GET /grades/1.json
  def show
    respond_to do |format|
      format.html {
        if params[:brief]
          render template: 'grades/brief.html.erb', layout: false
        else
          if @instructor
            render :show
          else
            render :show_staff
          end
        end
      }
      format.pdf {
        @signature_date = signature_date
        render pdf: %[Nilai],
               orientation: 'Portrait',
               template: 'grades/show.pdf.erb',
               layout: 'pdf_layout.html.erb'
      }
    end
  end

  def show_by_component
    if @component.id == @grade.component.id
      render json: @grade.score
    else
      render json: {}
    end
  end

  # GET /grades/new
  def new
    course = @students_record.pkg.course
    component = Component.find_by(course: course, is_default: true)
    #component = Component.where(course: course).order(:created_at).last
    raise ComponentNotFound unless component
    @component_options = Component.where(course: course).order(:id).to_a.map {|e|
      ["ID: #{'%02d' % e.id} / #{e.created_at.strftime("%e %b %Y, %H:%M")} #{e.is_default ? '(DEFAULT)' : ''}", e.id]
    }
    @grade = Grade.new(students_record: @students_record, instructor: @instructor, component: component)
  end

  # GET /grades/1/edit
  def edit
    course = @grade.component.course
    @component_options = Component.where(course: course).order(:id).to_a.map {|e|
      ["ID: #{'%02d' % e.id} / #{e.created_at.strftime("%e %b %Y, %H:%M")} #{e.is_default ? '(DEFAULT)' : ''}", e.id]
    }
  end

  # POST /grades
  # POST /grades.json
  def create
    @grade = Grade.new(grade_params)

    respond_to do |format|
      if @grade.valid? and ActiveRecord::Base.transaction_user(@current_user) { @grade.save! }
        format.html { redirect_to @grade, notice: 'Grade was successfully created.' }
        format.json { render :show, status: :created, location: @grade }
      else
        format.html { render :new }
        format.json { render json: @grade.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /grades/1
  # PATCH/PUT /grades/1.json
  def update
    respond_to do |format|
      if ActiveRecord::Base.transaction_user(@current_user) { @grade.update(grade_params) }
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

    def set_students_record
      @students_record = StudentsRecord.find(params[:id])
    end

    def set_current_user
      @current_user = current_user.username
    end

    def set_instructor
      @instructor = current_user.instructor
    end

    def set_component
      @component = Component.find(params[:component_id])
    end

    def generate_cert
      # find completed records eligible for cert, and generate it if any
      @grade.reload
      student = @grade.student
      student.eligible_for_certs {|course, grades|
        cert = Cert.new(student: student, course: course)
        cert.grades << grades
        cert.save!
      }
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def grade_params
      params[:grade]
      params.require(:grade).permit(:students_record_id, :instructor_id, :component_id).tap do |whitelisted|
                                        if params[:grade][:score]
                                          whitelisted[:score] = params[:grade][:score]
                                        end
                                      end
    end

    def signature_date
      DateTime.now.in_time_zone
    end
end
