class StudentsController < ApplicationController
  before_action :set_student, only: [:show, :edit, :update, :destroy, :attending, :remove_pkg]
  before_action :set_current_user, except: [:attending]
  before_action :set_current_group, except: [:attending]
  skip_before_action :authorize, only: [:attending]

  filter_access_to :all, :except => :name_suggestions

  helper_method :sort_column, :sort_direction
  
  def name_suggestions
    @suggestions = Student.fuzzy_search(name: params[:q])
  end
  
  def district_suggestions
    @districts = District.fuzzy_search(name: params[:q])
  end

  def regency_suggestions
    @regencies = RegenciesCity.fuzzy_search(name: params[:q])
  end
  
  def search
  end

  def attending
    now = DateTime.now.in_time_zone
    today = now.strftime("%a").downcase
    my_schedules = @student.students_pkgs_instructors_schedules
    @present_schedule = my_schedules.find do |my_schedule|
      if my_schedule.instructors_schedule.day == today
        start_time, end_time = my_schedule.instructors_schedule.schedule.time_slot.split(/\s+-\s+/).map {|e| Time.parse(e)}
        true if now > start_time - 30.minutes and now < start_time + 30.minutes
      end
    end
    if @present_schedule
      @study_time = @present_schedule.instructors_schedule.schedule.time_slot.split(/\s+-\s+/).first
    end
    respond_to do |format|
      format.text
    end
  end

  # DELETE
  def remove_pkg
    @student.transaction_user(@current_user) do
      pkg = Pkg.find(params[:pid])
      @student.pkgs.destroy(pkg)
    end
    respond_to do |format|
      format.html { redirect_to @student, notice: 'Student was successfully updated.' }
      format.json { render :show, status: :ok, location: @student }
    end
  end
      
  # GET /students
  # GET /students.json
  def index
    @filterrific = initialize_filterrific(
      Student,
      params[:filterrific],
      :select_options => {
        sorted_by: Student.options_for_sorted_by,
        with_religion: Student.options_for_religion
      }
    ) or return
    # @students = @filterrific.find.page(params[:page])
    @students = Student.filterrific_find(@filterrific).paginate(page: params[:page], per_page: 10)

    @active_students = StudentsRecord.joins(:student).where(student: @students, status: "active").inject({}) do |m,o|
      # all of taken pkgs have schedules?
      has_schedules = StudentsPkg.where(student: o.student).all? {|sp|
        sp.instructors_schedules.size > 0
      }
      m[o.student_id] = has_schedules
      m
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /students/1
  # GET /students/1.json
  def show
    @records = StudentsRecord.where(student: @student).order(:status, started_on: :desc)  #.order(params[:started_on])
    # @students_records = @student.records
  end

  # GET /students/new
  def new
    @student = Student.new
    @student.registered_at = DateTime.now.in_time_zone.to_date
  end

  # GET /students/1/edit
  def edit
  end

  # POST /students
  # POST /students.json
  def create
    @student = Student.new(student_params)
    @student.created_at = DateTime.now.in_time_zone

    respond_to do |format|
      if @student.valid? and @student.transaction_user(@current_user) { @student.save! }
        if params[:student][:avatar].blank?  
          redirect_to @student
          return  
        else  
          render :action => 'crop'
          return
        end  

        format.html { redirect_to @student, notice: 'Student was successfully created.' }
        format.json { render :show, status: :created, location: @student }
      else
        format.html { render :new }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /students/1
  # PATCH/PUT /students/1.json
  def update
    pkg_id = params.fetch(:student)[:pkg_id]
    if pkg_id and not pkg_id.empty?
      @student.transaction_user(@current_user) do
        pkg = Pkg.find(pkg_id)
        @student.pkgs << pkg if pkg
      end
    end

    if @student.transaction_user(@current_user) { @student.update(student_params) }
      flash[:notice] = "Successfully updated user."
      if params[:student][:avatar].blank?
        if params[:remove_avatar]
          @student.avatar = nil
          @student.save
        end
        redirect_to @student
      else  
        render :action => 'crop'
      end  
    else
      render :action => 'edit'
    end
  end

  # DELETE /students/1
  # DELETE /students/1.json
  def destroy
    @student.destroy
    respond_to do |format|
      format.html { redirect_to students_url, notice: 'Student was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_student
      @student = Student.find(params[:id])
    end

    def set_current_user
      @current_user = current_user.username
    end

    def set_current_group
      @current_group = current_user.group.name
    end
    
    # Never trust parameters from the scary internet, only allow the white list through.
    def student_params
      params.require(:student).permit(:name, :sex, :birthplace, :birthdate, :phone, :email, 
                                      :street_address, :district, :regency_city, :religion, :registered_at,
                                      :avatar, :crop_x, :crop_y, :crop_w, :crop_h).tap do |whitelisted|
                                        if params[:student][:biodata]
                                          whitelisted[:biodata] = params[:student][:biodata]
                                        end
                                      end
    end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ?  params[:direction] : "asc"
  end
  
  def sort_column
    Student.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end
end
