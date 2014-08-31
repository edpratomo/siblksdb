class StudentScheduleController < ApplicationController
  before_action :set_student, only: [:show, :edit, :select_pkg]

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

  def select_pkg
    @my_packages = @student.pkgs

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
  
  def edit
    unless params[:pkg]
      return redirect_to select_pkg_student_schedule_path(@student)
    end  

    ordered_days = %w(mon tue wed thu fri sat)

    @pkg = Pkg.find(params[:pkg][:id])
    @schedules = Schedule.order(:id)
    
    @pkgs_schedules_instructors = @schedules.map {|sch|
      pkgs_schedules = PkgsSchedule.where(pkg: @pkg, schedule: sch).inject({}) do |m,o|
        m[o.day] = o
        m
      end
      
      instructors_avail_seat = ordered_days.map {|day|
        PkgsSchedulesInstructor.joins(:instructor).where("pkgs_schedule_id = ?", pkgs_schedules[day].id).order(:instructor_id)
      }
      
      [sch.time_slot, *instructors_avail_seat]
    }
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
