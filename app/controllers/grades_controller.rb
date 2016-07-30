class GradesController < ApplicationController
  before_action :set_grade, only: [:show, :edit, :update, :destroy]
  before_action :set_students_record, only: [:new]
  before_action :set_current_user, only: [:update, :create, :destroy]
  before_action :set_instructor
  filter_resource_access

  # GET /grades
  # GET /grades.json
  def index
    if @instructor
      @filterrific = initialize_filterrific(
        StudentsRecord,
        params[:filterrific],
        :select_options => {
          sorted_by: StudentsRecord.options_for_sorted_by,
          with_pkg: @instructor.options_for_pkg
        },
        default_filter_params: { sorted_by: 'started_on_asc' }
      ) or return

      @students_records = StudentsRecord.with_instructor(@instructor).
                          filterrific_find(@filterrific).paginate(page: params[:page], per_page: 10)
    else # staff login
      render :index_staff
    end
  end

  # GET /grades/1
  # GET /grades/1.json
  def show
  end

  # GET /grades/new
  def new
    course = @students_record.pkg.course
    @grade = Grade.new(students_record: @students_record, instructor: @instructor, 
                       component: Component.find_by(course: course))
  end

  # GET /grades/1/edit
  def edit
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def grade_params
      params[:grade]
      params.require(:grade).permit(:students_record_id, :instructor_id, :component_id).tap do |whitelisted|
                                        if params[:grade][:value]
                                          whitelisted[:value] = params[:grade][:value]
                                        end
                                      end
    end
end
