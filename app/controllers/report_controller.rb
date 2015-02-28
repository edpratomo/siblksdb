class ReportController < ApplicationController
  def new_monthly_generic
  end

  def new_disnaker
  end

  def create_monthly_generic_summary
    @status = params[:status] || 'active'
    @status_for_title = status_for_title @status

    month, year = params[:month].to_i, params[:year].to_i
    dt = DateTime.new(year, month).in_time_zone
    @month_year_for_title = month_year_for_title @status, dt

    pkg_summary = StudentsRecord.joins(:student, :pkg => :program).
      send(:where, *args_for_where_clause(@status, dt)).
      group(:program, 'pkgs.pkg', :sex).count

    @students_group_by_pkg_sex = pkg_summary.inject({}) do |m,o|
      m["#{o[0][0]} - #{o[0][1]}"] ||= {"female" => 0, "male" => 0}
      m["#{o[0][0]} - #{o[0][1]}"][o[0][2]] = o[1]
      m
    end
      
    @total_students = pkg_summary.inject({"female" => 0, "male" => 0}) do |m,o|
      logger.info(o)
      m[o[0][2]] += o[1]
      m
    end
    
    students_group_by_religion = StudentsRecord.joins(:student).
      send(:where, *args_for_where_clause(@status, dt)).
      group(:religion).count

    @sorted_religions = students_group_by_religion.sort {|a,b| b[1] <=> a[1] }.map {|e| e[0]}

    @students_group_by_religion_and_sex = StudentsRecord.joins(:student).
      send(:where, *args_for_where_clause(@status, dt)).
      group(:religion, :sex).count.
    inject({}) do |m,o|
      m[o[0][0]] ||= {"female" => 0, "male" => 0}
      m[o[0][0]][o[0][1]] = o[1]
      m
    end
    #logger.info(@students_group_by_religion_and_sex)
        
    respond_to do |format|
      format.html { render :create_monthly_generic_summary }
      format.pdf { 
        render pdf: %[Laporan_Rekapitulasi_Siswa_#{I18n.t(@status).capitalize}_#{I18n.l(dt, format: "%B_%Y")}],
               orientation: 'Portrait',
               template: 'report/create_monthly_generic_summary.pdf.erb',
               layout: 'pdf_layout.html.erb'
      }
    end
  end
  
  def create_monthly_generic
    if params[:summary] 
      if params[:print_pdf]
        redirect_to report_create_monthly_generic_summary_path(:format => 'pdf', :status => params[:status], 
                                                               :month => params[:month], :year => params[:year])
      else
        redirect_to report_create_monthly_generic_summary_path(:status => params[:status], 
                                                               :month => params[:month], :year => params[:year])
      end
      return
    end
    
    @status = params[:status] || 'active'
    @status_for_title = status_for_title @status

    month, year = params[:month].to_i, params[:year].to_i
    dt = DateTime.new(year, month).in_time_zone
    @month_year_for_title = month_year_for_title @status, dt

    @students = StudentsRecord.joins(:student).send(:where, *args_for_where_clause(@status, dt)).
      order("students.name")

    respond_to do |format|
      format.html { 
        @students = @students.paginate(:per_page => 10, :page => params[:page]) 
        render :create_monthly_generic
      }
      format.pdf { 
        render pdf: %[Laporan_Bulanan_Siswa_#{I18n.t(@status).capitalize}_#{I18n.l(dt, format: "%B_%Y")}],
               orientation: 'Landscape',
               template: 'report/create_monthly_generic.pdf.erb',
               layout: 'pdf_layout.html.erb'
      }
    end
  end
  
  def create_disnaker
    month, year = params[:month].to_i, params[:year].to_i
    now = DateTime.new(year, month).in_time_zone
    @month_year_for_title = now.end_of_month.strftime("%d %B %Y")
    @columns = []
    @result = [2, 1, 0].map do |e|
      dt = now - e.month
      month, year = dt.month, dt.year
      @columns.push "#{dt.strftime('%B')} #{year}"
      
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
          where("sex = ? AND status = 'finished' AND date_part('month', finished_on) = ? AND date_part('year', finished_on) = ?", 
          o, month, year).
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
      format.html { render :create_disnaker }
      format.pdf { 
        render pdf: %[Laporan_Pelaksanaan_Pelatihan_#{I18n.l(now, format: "%B_%Y")}],
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

  def args_for_where_clause status, dt
    case status
    when "active"
      [ "started_on < ? AND (status = 'active' OR finished_on > ?)", dt.end_of_month, dt.end_of_month ]
    when "finished", "failed", "abandoned"
      [ "started_on < ? AND status = ? AND date_part('month', finished_on) = ? AND date_part('year', finished_on) = ?", 
        dt.end_of_month, status, dt.month, dt.year ]
    end
  end

  def status_for_title status
    case status
    when "active"
      "under training"
    else
      status
    end
  end

  def month_year_for_title status, dt
    if status == "active"
      dt.end_of_month
    else
      dt
    end
  end
end
