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
    
    @pkg = Pkg.find(params[:pkg])
    @sch = Schedule.find(params[:schedule])
    
    ordered_days = %w(mon tue wed thu fri sat)

    @schedules = if @pkg and @sch
      # find students who take this pkg
      # XXX - no idea how to do multi join (with :schedules) here, should revisit
      students = Student.joins(:pkgs).where("pkgs.id = ?", @pkg.id).order(name: :asc)
      
      students.map {|student|
        my_schedule = StudentsPkg.find_by(student: student, pkg: @pkg).pkgs_schedules.where(schedule: @sch).inject({}) do |m,o|
          m[o.day] = true
          m
        end
        logger.debug("my_schedule: #{my_schedule}")
        [student.name, *ordered_days.map {|e| my_schedule[e] }]
      }.reject {|e| e[1..6].all? {|e| not e }}
    else 
      []
    end

  end
end
