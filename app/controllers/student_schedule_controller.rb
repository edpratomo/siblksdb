class StudentScheduleController < ApplicationController
  before_action :set_student, only: [:show, :edit]

  def index
  end

  def new
  end

  def create
  end
  
  def update
    student_pkg = StudentsPkg.find(params.fetch(:students_pkg)[:id])

    my_ps_ids = params.fetch(:students_pkg)[:pkgs_schedule_ids] || []
    my_ps = my_ps_ids.map {|e| PkgsSchedule.find(e) }

    unless student_pkg.pkgs_schedules == my_ps
      logger.debug("Updating students_pkgs_schedules")
      student_pkg.pkgs_schedules = my_ps
      
      # join table
      student_pkg_schedules = StudentsPkgsSchedule.where(students_pkg: student_pkg, pkgs_schedule: my_ps)
      student_pkg_schedules.update_all(modified_by: current_user)
    end

    respond_to do |format|
      if student_pkg.update(students_pkg_params)
        format.html { redirect_to student_schedule_url, notice: 'Schedule was successfully updated.' }
        format.json { render :show, status: :created, location: @student_schedule }
      else
        format.html { render :edit }
        format.json { render json: @student_schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
  end

  def edit
    @packages_taken = @student.pkgs
    @schedules = Schedule.order(:id)    
  end

  # show this student's schedules
  def show
    @packages_taken = @student.pkgs
    @schedules = Schedule.order(:id)    
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_student
    @student = Student.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def student_params
    params.require(:student).permit(:name, :sex, :birthplace, :birthdate, :phone, :note, :modified_by)
  end

  def students_pkg_params
    params.require(:students_pkg).permit(:id, :pkgs_schedule_ids)
  end
end
