class StudentScheduleController < ApplicationController
  before_action :set_student, only: [:show, :new]

  def index
  end

  def new

  end

  def create
  end

  def destroy
  end

  def edit
  end

  # show this student's schedules
  def show
    @packages_taken = StudentsPkg.find_by(student: @student)
    
    #@student_schedules = @student.pkgs
    #.schedules
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

end
