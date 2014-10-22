class ReportController < ApplicationController
  def new_active_students
  end

  def new_disnaker
  end

  def create_active_students
    month, year = params[:month].to_i, params[:year].to_i
    dt = DateTime.new(year, month)
    @month_year_for_title = dt.end_of_month.strftime("%d %B %Y")

    @students = StudentsRecord.joins(:student).
      where("started_on < ? AND (status = 'active' OR finished_on > ?)", dt.end_of_month, dt.end_of_month).
      order("students.name")
  end
  
  def create_disnaker
    now = DateTime.now
    @columns = []
    @result = [3, 2, 1].map do |e|
      dt = now - e.month
      month, year = dt.month, dt.year
      @columns.push "#{dt.strftime("%B")} #{year}"
      
      [nil, 'female', 'male'].inject({}) do |m,o|
        if o.nil?
          sex_clause_and = ''
          key = 'any'
        else
          sex_clause_and = "sex = '#{o}' AND"
          key = o.dup
        end

        m[key] ||= {}

        # active students
        active_students = StudentsRecord.joins(:student).
          where("#{sex_clause_and} started_on < ? AND (status = 'active' OR finished_on > ?)", 
          dt.end_of_month, dt.end_of_month).
          group(:pkg).count

        m[key][:active] = active_students.inject({}) do |m1,o1|
          # logger.info o1
          m1[pkg_to_s(o1.first)] = o1.second
          m1
        end

        # finished students
        finished_students = StudentsRecord.joins(:student).
          where("sex = '#{o}' AND status = 'finished' AND date_part('month', finished_on) = ? AND date_part('year', finished_on) = ?", 
          month, year).
          group(:pkg).count
        
        m[key][:finished] = finished_students.inject({}) do |m1,o1|
          m1[pkg_to_s(o1.first)] = o1.second
          m1
        end

        m
      end
    end
    # merge keys
    @sorted_keys = @result.inject([]) do |m,o|
      m = m | o['any'][:active].keys | o['any'][:finished].keys
      m
    end.sort
  end
  
  private
  def pkg_to_s pkg
    sprintf("#{pkg.program.program} - #{pkg.pkg} - %2d", pkg.level)
  end
end
