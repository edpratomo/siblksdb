class StudentsController < ApplicationController
  before_action :set_student, only: [:show, :edit, :update, :destroy, :manage_pkg, :finish_pkg, :remove_pkg]
  before_action :set_current_user
  
  helper_method :sort_column, :sort_direction
  
  def name_suggestions
    @suggestions = Student.fuzzy_search(name: params[:q])
  end
  
  def search
  end

  # DELETE
  def finish_pkg
    @student.transaction_user(@current_user) do
      pkg = Pkg.find(params[:pid])
      @student.qualifications << pkg
      @student.pkgs.destroy(pkg)
    end
    respond_to do |format|
      format.html { redirect_to @student, notice: 'Student was successfully updated.' }
      format.json { render :show, status: :ok, location: @student }
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
      
  def manage_pkg
    @my_packages = @student.pkgs.order(:id)
    ordered_pkg_names = Pkg.select("distinct pkg").order(pkg: :desc).map {|e| e.pkg}
    
    all_pkgs = Pkg.order(pkg: :desc).order(:level)
    pkg_hash = all_pkgs.inject({}) do |m,o|
      m[o.pkg] ||= OpenStruct.new(pkg_name: o.pkg, levels: [])
      m[o.pkg].levels << OpenStruct.new(level: "#{o.pkg} Level #{o.level}", id: o.id)
      m
    end

    # finally create the collection obj
    @packages = ordered_pkg_names.map {|e| pkg_hash[e] }
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
      params.require(:student).permit(:name, :sex, :birthplace, :birthdate, :phone, :note, :avatar, :crop_x, :crop_y, :crop_w, :crop_h)
    end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ?  params[:direction] : "asc"
  end
  
  def sort_column
    Student.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end
end
