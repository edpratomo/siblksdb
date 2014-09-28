class StudentsRecordsController < ApplicationController
  # before_action :set_students_record, only: [:show, :edit, :update, :destroy]
  before_action :set_student, only: [:new, :create, :show, :edit, :update, :destroy]

  # GET /students_records
  # GET /students_records.json
  def index
    @students_records = @student.records
  end

  # GET /students_records/1
  # GET /students_records/1.json
  def show
    @records = StudentsRecord.where(student: @student).order(params[:started_on])
  end

  # GET /students_records/new
  def new
    # ordered_pkg_names = Pkg.select("distinct pkg").order(pkg: :desc).map {|e| e.pkg}
    all_pkgs = Pkg.order(pkg: :desc).order(:level)
    @grouped_options = all_pkgs.inject({}) do |m,o|
      m[o.program.program] ||= []
      m[o.program.program] << [ "#{o.pkg} Level #{o.level}", o.id ]
      m
    end
  end

  # GET /students_records/1/edit
  def edit
  end

  # POST /students_records
  # POST /students_records.json
  def create
    pkg = Pkg.find(params[:pkg_id])

    params_new = {
      student: @student,
      pkg: pkg,
      started_on: params[:started_on],
      finished_on: params[:finished_on],
      status: (params[:finished_on].empty? ? 'active' : 'finished')
    }

    @students_record = StudentsRecord.new(params_new)

    respond_to do |format|
      if @student.transaction_user(@current_user) {
        if params[:finished_on].empty?
          @student.pkgs << pkg
        end
        @students_record.save
      }
        format.html { redirect_to students_record_url(@student), notice: 'Students record was successfully created.' }
        format.json { render :show, status: :created, location: @students_record }
      else
        format.html { render :new }
        format.json { render json: @students_record.errors, status: :unprocessable_entity }
      end
    end

  end

  # PATCH/PUT /students_records/1
  # PATCH/PUT /students_records/1.json
  def update
    respond_to do |format|
      if @students_record.update(students_record_params)
        format.html { redirect_to @students_record, notice: 'Students record was successfully updated.' }
        format.json { render :show, status: :ok, location: @students_record }
      else
        format.html { render :edit }
        format.json { render json: @students_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /students_records/1
  # DELETE /students_records/1.json
  def destroy
    @students_record.destroy
    respond_to do |format|
      format.html { redirect_to students_records_url, notice: 'Students record was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    #def set_students_record
    #  @students_record = StudentsRecord.find(params[:id])
    #end

    # Never trust parameters from the scary internet, only allow the white list through.
    def students_record_params
      params.require(:students_record).permit(:student_id, :pkg_id, :started_on, :finished_on, :status, :modified_at, :modified_by)
    end

    def set_student
      @student = Student.find(params[:id])
    end

    def set_current_user
      @current_user = current_user.username
    end
end
