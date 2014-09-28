class StudentsRecordsController < ApplicationController
  # before_action :set_students_record, only: [:show, :edit, :update, :destroy]
  before_action :set_student, only: [:show, :edit, :update, :destroy]

  # GET /students_records
  # GET /students_records.json
  def index
    @students_records = StudentsRecord.all
  end

  # GET /students_records/1
  # GET /students_records/1.json
  def show
  end

  # GET /students_records/new
  def new
    @students_record = StudentsRecord.new
  end

  # GET /students_records/1/edit
  def edit
  end

  # POST /students_records
  # POST /students_records.json
  def create
    @students_record = StudentsRecord.new(students_record_params)

    respond_to do |format|
      if @students_record.save
        format.html { redirect_to @students_record, notice: 'Students record was successfully created.' }
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
