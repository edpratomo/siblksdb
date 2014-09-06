class PresenceSheetController < ApplicationController
  def new
  end

  def show
  end
  
  def create
    start_day = if params[:time_range] == "next_week"
      DateTime.now.to_date.beginning_of_week.advance(:days => 7)
    else
      DateTime.now.to_date.beginning_of_week
    end

    # table heading contains dates from mon to sat
    @dates = (1..5).to_a.inject([start_day]) do |m,o|
      m << start_day.advance(days: o)
      m
    end
    
    @instructor = Instructor.find(params[:instructor])
    @sched = Schedule.find(params[:schedule])
    
    ordered_days = %w(mon tue wed thu fri sat)

    @student_vs_day = if @instructor and @sched
      students_pkgs_by_day = @instructor.instructors_schedules.where(schedule: @sched).inject({}) do |m,o|
        m[o.day] = o.students_pkgs.inject({}) do |m1,o1|
          m1[o1.student.name] = o1.pkg.pkg
          m1
        end
        m
      end
      
      students = @instructor.students.order(name: :asc).uniq
      students.map do |student|
        student_schedule = ordered_days.map do |day|
          students_pkgs_by_day[day] ||= {}
          students_pkgs_by_day[day][student.name] #|| ''
        end  
        [student.name, *student_schedule]
      end
    else 
      []
    end
  end
end
