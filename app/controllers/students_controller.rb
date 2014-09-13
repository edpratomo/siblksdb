class StudentsController < ApplicationController
  before_action :set_student, only: [:show, :edit, :update, :destroy, :manage_pkg]

  helper_method :sort_column, :sort_direction
  
  def name_suggestions
    @suggestions = Student.fuzzy_search(name: params[:q])
  end
  
  def search
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
    username = current_user.username

    respond_to do |format|
      if @student.transaction_user(username) { @student.save }
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
    username = current_user.username
    pkg_id = params.fetch(:student)[:pkg_id]
    if pkg_id and not pkg_id.empty?
      @student.transaction_user(username) do
        pkg = Pkg.find(pkg_id)
        @student.pkgs << pkg if pkg
      end
    end
      
    remove_pkgs = params[:remove_pkgs]
    if remove_pkgs
      @student.transaction_user(username) do
        remove_pkgs.map {|e| Pkg.find(e)}.each do |pkg|
          @student.pkgs.destroy(pkg)
        end
      end
    end
    
    respond_to do |format|
      if @student.transaction_user(username) { @student.update(student_params) }
        format.html { redirect_to @student, notice: 'Student was successfully updated.' }
        format.json { render :show, status: :ok, location: @student }
      else
        format.html { render :edit }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def student_params
      params.require(:student).permit(:name, :sex, :birthplace, :birthdate, :phone, :note)
    end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ?  params[:direction] : "asc"
  end
  
  def sort_column
    Student.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end
end
