class StudentScheduleController < ApplicationController
  before_action :set_student,      only: [:show, :edit]
  before_action :set_students_pkg, only: [:update]
  
  def index
  end

  def new
  end

  def create
  end
  
  def update
    username = current_user.username
    student = @students_pkg.student
    chosen_instructors_schedules = if params[:students_pkg]
      params[:students_pkg][:instructors_schedule_ids].map {|e| InstructorsSchedule.find(e) }
    else
      []
    end

    unless @students_pkg.instructors_schedules == chosen_instructors_schedules
      logger.debug("Updating students_pkgs_instructors_schedules")
      @students_pkg.transaction_user(username) {
        @students_pkg.instructors_schedules = chosen_instructors_schedules
      }
    end

    respond_to do |format|
      if true # @students_pkg.update(students_pkg_params)
        format.html { redirect_to student_schedule_url(student), notice: 'Schedule was successfully updated.' }
        format.json { render :show, status: :created, location: student_schedule_url(student) }
      else
        format.html { render :edit }
        format.json { render json: @student_schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
  end

  def edit
    pkgs = [ Pkg.find(params[:pkg_id]) ]
    ordered_days = %w(mon tue wed thu fri sat)
    schedules = Schedule.order(:id)
    
    css_colors = %w[aqua blue fuchsia gray green lime maroon navy olive orange purple red silver teal yellow]
    iterator = gen_iterator
    @instructors_colors = Instructor.all.map {|e| e.nick }.inject({}) do |m,o|
      m[o] = iterator.call(css_colors)
      m
    end
    @my_packages = pkgs.map do |pkg|
      instructors = pkg.program.instructors
      schedules_by_day = {}
      instructors.each do |instructor|
        instructor.instructors_schedules.each do |i_schedule|
          schedules_by_day[i_schedule.day] ||= []
          schedules_by_day[i_schedule.day] << i_schedule
        end
      end
      timeslot_vs_day = schedules.map do |sched|
        instructors_schedules = ordered_days.map do |day|
          (schedules_by_day[day] || []).select do |i_schedule|
            i_schedule.schedule == sched
          end
        end
        [sched.time_slot, *instructors_schedules]
      end
      {
        name: "#{pkg.pkg} Level #{pkg.level}",
        students_pkg: StudentsPkg.find_by(student: @student, pkg: pkg),
        rowspan: instructors.size, 
        rows: timeslot_vs_day
      }
    end
  end

  # show this student's schedules
  def show
    pkgs = @student.pkgs.order(:id)
    ordered_days = %w(mon tue wed thu fri sat)
    schedules = Schedule.order(:id)

    @my_packages = pkgs.map do |pkg|
      students_pkg = StudentsPkg.find_by(student: @student, pkg: pkg)
      my_schedule = students_pkg.instructors_schedules.inject({}) do |m,o|
        m[o.id] = true
        m
      end
      logger.debug("my_schedule #{my_schedule}")
      instructors = pkg.program.instructors
      schedules_by_day = {}
      instructors.each do |instructor|
        instructor.instructors_schedules.each do |i_schedule|
          schedules_by_day[i_schedule.day] ||= []
          schedules_by_day[i_schedule.day] << i_schedule
        end
      end
      timeslot_vs_day = schedules.map do |sched|
        instructors_schedules = ordered_days.map do |day|
          found = (schedules_by_day[day] || []).find {|e| e.schedule == sched and my_schedule[e.id]}
          found ? found.instructor.nick : "-"
        end
        [sched.time_slot, *instructors_schedules]
      end
      {
        name: "#{pkg.pkg} Level #{pkg.level}",
        students_pkg: students_pkg,
        rowspan: instructors.size, 
        rows: timeslot_vs_day,
        id: pkg.id
      }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_student
    @student = Student.find(params[:id])
  end

  def set_students_pkg
    @students_pkg = StudentsPkg.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def student_params
    params.require(:student).permit(:name, :sex, :birthplace, :birthdate, :phone, :note)
  end

  def students_pkg_params
    params.require(:students_pkg).permit(:id, :instructors_schedule_ids)
  end

  # circular iterator
  def gen_iterator
    idx = 0
    -> (items) { idx += 1; idx = 1 if idx > items.size; items[idx - 1] }
  end
end
