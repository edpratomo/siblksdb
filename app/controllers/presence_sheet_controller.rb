class PresenceSheetController < ApplicationController
  def new
  end

  def show
  end
  
  def create
    start_day = if params[:time_range] == "next_week"
      DateTime.now.in_time_zone.to_date.beginning_of_week.advance(:days => 7)
    else
      DateTime.now.in_time_zone.to_date.beginning_of_week
    end

    # table heading contains dates from mon to sat
    @dates = (1..5).to_a.inject([start_day]) do |m,o|
      m << start_day.advance(days: o)
      m
    end

    holidays_setting = Setting.holidays
    @holidays = @dates.map {|e| holidays_setting[e.strftime("%Y-%m-%d")]}
    
    @instructor = Instructor.find(params[:instructor])
    @sched = Schedule.find(params[:schedule])
    
    ordered_days = %w(mon tue wed thu fri sat)

    @student_vs_day = if @instructor and @sched
      students_pkgs_by_day = @instructor.instructors_schedules.where(schedule: @sched).inject({}) do |m,o|
        m[o.day] = o.students_pkgs.inject({}) do |m1,o1|
          m1[o1.student.name] = "#{o1.pkg.pkg} / Lev. #{o1.pkg.level}"
          m1
        end
        m
      end
      
      students = @instructor.students.order(name: :asc).uniq
      students.map do |student|
        student_schedule = ordered_days.map do |day|
          students_pkgs_by_day[day] ||= {}
          students_pkgs_by_day[day][student.name] 
        end  
        [student.name, *student_schedule]
      end.reject {|e| e[1..6].all? {|e| not e }} # exclude students with empty schedules
    else 
      []
    end

    respond_to do |format|
      if true # @students_pkg.update(students_pkg_params)
        # format.html { redirect_to student_schedule_url(student), notice: 'Schedule was successfully updated.' }
        format.html { render :create }
        format.pdf { 
          render pdf: %[Absensi_#{@instructor.name.gsub(' ', '_')}_#{start_day.strftime("%d-%m-%Y")}],
                 orientation: 'Landscape',
                 template: 'presence_sheet/create.pdf.erb',
                 layout: 'pdf_layout.html.erb'
        }
        format.json { render :show, status: :created, location: student_schedule_url(student) }
      else
        format.html { render :edit }
        format.json { render json: @student_schedule.errors, status: :unprocessable_entity }
      end
    end
  end
end
