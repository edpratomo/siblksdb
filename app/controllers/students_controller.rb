class StudentsController < ApplicationController
  before_action :set_student, only: [:show, :edit, :update, :destroy, :attending, :remove_pkg]
  before_action :set_current_user
  
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
    now = DateTime.now
    today = now.strftime("%a").downcase
    my_schedules = @student.students_pkgs_instructors_schedules
    @present_schedule = my_schedules.find do |my_schedule|
      if my_schedule.instructors_schedule.day == today
        start_time, end_time = my_schedule.instructors_schedule.schedule.time_slot.split(/\s+-\s+/).map {|e| Time.parse(e)}
        true if now > start_time - 30.minutes and now < start_time + 30.minutes
      end
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
    @students = Student.order(sort_column + ' ' + sort_direction).paginate(:per_page => 10, :page => params[:page]) 
  end

  # GET /students/1
  # GET /students/1.json
  def show
  end

  # GET /students/new
  def new
    @student = Student.new
  end

  # GET /students/1/edit
  def edit
  end

  # POST /students
  # POST /students.json
  def create
    @student = Student.new(student_params)

    respond_to do |format|
      if @student.transaction_user(@current_user) { @student.save! }
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
    
    # Never trust parameters from the scary internet, only allow the white list through.
    def student_params
      params.require(:student).permit(:name, :sex, :birthplace, :birthdate, :phone, :note, 
                                      :street_address, :district, :regency_city, :religion,
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
