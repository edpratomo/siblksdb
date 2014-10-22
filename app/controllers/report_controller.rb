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

    respond_to do |format|
      format.html { render :create }
      format.pdf { 
        render pdf: %[Laporan_Siswa_Aktif_#{Date::MONTHNAMES[month]}_#{year}],
               orientation: 'Landscape',
               template: 'report/create_active_students.pdf.erb',
               layout: 'pdf_layout.html.erb'
      }
    end
  end
  
  def create_disnaker
    month, year = params[:month].to_i, params[:year].to_i
    now = DateTime.new(year, month)
    @columns = []
    @result = [2, 1, 0].map do |e|
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

    respond_to do |format|
      format.html { render :create }
      format.pdf { 
        render pdf: %[Laporan_Pelaksanaan_Pelatihan_#{Date::MONTHNAMES[month]}_#{year}],
               orientation: 'Landscape',
               template: 'report/create_disnaker.pdf.erb',
               layout: 'pdf_layout.html.erb'
      }
    end
  end
  
  private
  def pkg_to_s pkg
    sprintf("#{pkg.program.program} - #{pkg.pkg} - %2d", pkg.level)
  end
end
