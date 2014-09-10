class StudentsController < ApplicationController
  before_action :set_student, only: [:show, :edit, :update, :destroy, :manage_pkg]

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
    @students = Student.order(:name).paginate(:per_page => 10, :page => params[:page]) 
  end

  # GET /students/1
  # GET /students/1.json
  def show
  end

  # GET /students/new
  def new
    @student = Student.new
    @packages = Pkg.where("level = 1").order(:id)
  end

  # GET /students/1/edit
  def edit
  end

  # POST /students
  # POST /students.json
  def create
    @student = Student.new(student_params)
    @student.user = current_user

    respond_to do |format|
      if @student.save
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
    respond_to do |format|
      @student.user = current_user
      
      pkg_id = params.fetch(:student)[:pkg_id]
      if pkg_id and not pkg_id.empty?
        Student.transaction do 
          Pkg.transaction do
            pkg = Pkg.find(pkg_id)
            @student.pkgs << pkg if pkg
          end
        end
      end
      
      remove_pkgs = params[:remove_pkgs]
      if remove_pkgs 
        remove_pkgs.map {|e| Pkg.find(e)}.each do |pkg|
          @student.pkgs.destroy(pkg)
        end
      end
        
      if @student.update(student_params)
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
end
