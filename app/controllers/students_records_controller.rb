class StudentsRecordsController < ApplicationController
  # before_action :set_students_record, only: [:show, :edit, :update, :destroy]
  before_action :set_student, only: [:new, :show]
  before_action :set_students_record, only: [:edit, :update, :destroy]
  before_action :set_grouped_pkg_options, only: [:new, :update]
  before_action :set_current_user
  before_action :set_current_group
  
  # GET /students_records
  # GET /students_records.json
  def index
    @students_records = @student.records
  end

  # GET /students_records/1
  # GET /students_records/1.json
  def show
    #@records = StudentsRecord.where(student: @student).order(params[:started_on])
    @records = StudentsRecord.where(student: @student).order(:status, started_on: :desc)
  end

  # GET /students_records/new
  def new
    @students_record = StudentsRecord.new
    @students_record.student = @student
    @students_record.status = "active"
    @students_record.started_on = Date.today # default value for started_on
  end

  # GET /students_records/1/edit
  def edit
    @students_record = StudentsRecord.find(params[:id])
    @student = @students_record.student
  end

  # POST /students_records
  # POST /students_records.json
  def create
    #params[:students_record][:status] = (params[:students_record][:finished_on].empty? ? 'active' : 'finished')
    @students_record = StudentsRecord.new(students_record_params)
    @student = Student.find(params[:students_record][:student_id])

    respond_to do |format|
      if @students_record.valid? and ActiveRecord::Base.transaction_user(@current_user) {
        @students_record.save!
        pkg = Pkg.find(params[:students_record][:pkg_id])
        @student.pkgs << pkg # this student has just started a pkg
      }
        format.html {
          flash[:success] = 'Students record was successfully created.'
          redirect_to students_record_url(@student)
        }
        format.json { render :show, status: :created, location: @students_record }
      else
        set_grouped_pkg_options
        format.html { render :new }
        format.json { render json: @students_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /students_records/1
  # PATCH/PUT /students_records/1.json
  def update
    @student = @students_record.student
    respond_to do |format|
      if @students_record.valid? and ActiveRecord::Base.transaction_user(@current_user) {
        if @students_record.grade
          if params[:students_record][:status] == "finished" and @students_record.status != "finished"
            if @students_record.grade.passed?
              params[:students_record][:finished_on] ||= DateTime.now.in_time_zone.to_date
              pkg = Pkg.find(params[:students_record][:pkg_id])
              if pkg
                @student.pkgs.destroy(pkg) # this student has finished a pkg
              end
              @students_record.update(students_record_params)
              flash[:success] = 'Students record was successfully updated. Schedule was deleted.'

              course = @students_record.pkg.course
              unless Cert.find_by(student: @student, course: course)
                # check for course completion
                course_max_level = Pkg.where(course: course).maximum(:level)
                if @students_record.pkg.level == course_max_level
                  records_for_this_course = StudentsRecord.where(student: @student, status: "finished").select {|sr|
                    sr.grade and sr.grade.component.course == course
                  }
                  finished_levels = records_for_this_course.map {|sr| sr.pkg.level}.sort
                  if (1..course_max_level).all? {|level| finished_levels.member?(level) }
                    # completed all levels, create new Cert
                    cert = Cert.new(student: @student, course: course)
                    cert.grades << records_for_this_course.map {|sr| sr.grade }
                    cert.save!
                  else
                    logger.debug("cert not created. finished_levels: #{finished_levels.join(', ')}")
                  end
                end
              end
            else
              flash[:alert] = %[Error: this student's grade does not qualify.]
            end
          elsif params[:students_record][:status] == "abandoned" and @students_record.status != "abandoned"
            flash[:alert] = "Error: this student has taken the exam for this subject."
            # params[:students_record].delete(:finished_on)
            # params[:students_record].delete(:status)
          else
            @students_record.update(students_record_params)
            if request.format.html?
              flash[:success] = 'Students record was successfully updated.'
            end
          end
        else
          if params[:students_record][:status] == "finished" and @students_record.status != "finished"
            students_pkg = StudentsPkg.find_by(student: @students_record.student, pkg: @students_record.pkg)
            instructor_ids = students_pkg.instructors_schedules.map {|e| e.instructor_id}.uniq
            if instructor_ids.size > 1
              flash[:alert] = "Error: Lebih dari satu instruktur."
              next
            else
              course = @students_record.pkg.course
              component = Component.where(course: course).order(:created_at).last
              # create empty grade
              grade = Grade.new(students_record: @students_record, 
                                instructor_id: instructor_ids.first,
                                component: component)
              grade.save!
              @students_record.grade = grade
              @students_record.save!
            end
          end
          unless params[:students_record][:finished_on].empty?
            pkg = Pkg.find(params[:students_record][:pkg_id])
            if pkg
              @student.pkgs.destroy(pkg) # this student has finished a pkg
            end
            # this is now controlled by check_box:
            # params[:students_record][:status] ||= 'finished'
          else
            params[:students_record][:status] = 'active'
          end
          @students_record.update(students_record_params)
          if request.format.html?
            flash[:success] = 'Students record was successfully updated.'
          end
        end
      }
        format.html {
          redirect_to students_record_url(@student)
        }
        format.json { render :show, status: :ok, location: @students_record }
      else
        set_grouped_pkg_options
        format.html { render :edit }
        format.json { render json: @students_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /students_records/1
  # DELETE /students_records/1.json
  def destroy
    @student = @students_record.student
    destroyed = ActiveRecord::Base.transaction_user(@current_user) {
      if (@current_group == "sysadmin" and @students_record.status != "active") or
         @students_record.destroyable?
        @student.pkgs.destroy(@students_record.pkg)
        @students_record.destroy
      end
    }
    logger.info("redirect to #{students_record_url(@student)}")
    respond_to do |format|
      if destroyed
        format.html {
          flash[:success] = 'Students record was successfully destroyed.'
          redirect_to students_record_url(@student)
        }
        format.json { head :no_content }
      else
        format.html {
          flash[:alert] = 'Students record was NOT destroyed.'
          redirect_to students_record_url(@student)
        }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_students_record
      @students_record = StudentsRecord.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def students_record_params
      params.require(:students_record).permit(:student_id, :pkg_id, :started_on, :finished_on, :status)
    end

    def set_grouped_pkg_options
      #all_pkgs = Pkg.order(pkg: :desc).order(:level)
      all_pkgs = Pkg.joins(:course).order("courses.name DESC").order(:level)
      @grouped_options = all_pkgs.inject({}) do |m,o|
        m[o.program.program] ||= []
        m[o.program.program] << [ "#{o.pkg} Level #{o.level}", o.id ]
        m
      end
    end
    
    def set_student
      @student = Student.find(params[:id])
    end

    def set_current_user
      @current_user = current_user.username
    end

    def set_current_group
      @current_group = current_user.group.name
    end
end
