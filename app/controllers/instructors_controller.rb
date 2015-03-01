class InstructorsController < ApplicationController
  before_action :set_instructor, only: [:show, :edit, :update, :destroy, :edit_schedule, :update_schedule]
  before_action :set_current_user, only: [:update, :update_schedule, :create, :destroy]
  # before_action :authorize_admin, only: [:create, :edit, :update, :destroy]
  filter_resource_access

  # GET /instructors
  # GET /instructors.json
  def index
    @instructors = Instructor.order(:name)
  end

  # GET /instructors/1
  # GET /instructors/1.json
  def show
  end

  def edit_schedule
    ordered_days = %w(mon tue wed thu fri sat)
    schedules = Schedule.order(:id)
    @checked_schedules = InstructorsSchedule.where(instructor: @instructor).inject({}) do |m,o|
      m["#{o.schedule_id}_#{o.day}"] = true
      m
    end
    @schedules_vs_days = schedules.map do |sched|
      ["#{sched.label} (#{sched.time_slot})", *ordered_days.map {|day| "#{sched.id}_#{day}" }]
    end
  end

  def update_schedule
    current_schedules = InstructorsSchedule.where(instructor: @instructor).map {|e| "#{e.schedule_id}_#{e.day}"}
    added = params[:instructor][:schedule_ids] - current_schedules
    deleted = current_schedules - params[:instructor][:schedule_ids]
    
    added.each do |to_add|
      schedule_id, day = to_add.split('_')
      instructor_schedule = InstructorsSchedule.new(instructor: @instructor, schedule_id: schedule_id.to_i, day: day)
      instructor_schedule.transaction_user(@current_user) { instructor_schedule.save }
    end

    deleted.each do |to_add|
      schedule_id, day = to_add.split('_')
      instructor_schedule = InstructorsSchedule.find_by(instructor: @instructor, schedule_id: schedule_id.to_i, day: day)
      instructor_schedule.transaction_user(@current_user) { instructor_schedule.destroy }
    end

    respond_to do |format|
      if true # @instructor.update(instructor_params)
        format.html { redirect_to @instructor, notice: 'Instructor was successfully updated.' }
        format.json { render :show, status: :ok, location: @instructor }
      else
        format.html { render :edit }
        format.json { render json: @instructor.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # GET /instructors/new
  def new
    @instructor = Instructor.new
    @programs = Program.order(:id)
  end

  # GET /instructors/1/edit
  def edit
    @programs = Program.order(:id)
    @checked_programs = @instructor.programs
  end

  # POST /instructors
  # POST /instructors.json
  def create
    @instructor = Instructor.new(instructor_params)
    logger.debug("program_ids: #{params[:instructor][:program_ids]}")
    if params[:instructor][:program_ids] # not automatic? 
      @instructor.programs = params[:instructor][:program_ids].map {|e| Program.find(e)}.compact
    end
    respond_to do |format|
      if @instructor.transaction_user(@current_user) { @instructor.save }
        if params[:init_default_schedule]
          ActiveRecord::Base.connection.execute("SELECT initialize_instructors_schedules(#{@instructor.id})")
        end
        format.html { redirect_to @instructor, notice: 'Instructor was successfully created.' }
        format.json { render :show, status: :created, location: @instructor }
      else
        format.html { redirect_to new_instructor_url }
        format.json { render json: @instructor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /instructors/1
  # PATCH/PUT /instructors/1.json
  def update
    respond_to do |format|
      if @instructor.transaction_user(@current_user) { @instructor.update(instructor_params) }
        format.html { redirect_to @instructor, notice: 'Instructor was successfully updated.' }
        format.json { render :show, status: :ok, location: @instructor }
      else
        format.html { render :edit }
        format.json { render json: @instructor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /instructors/1
  # DELETE /instructors/1.json
  def destroy
    @instructor.transaction_user(@current_user) { @instructor.destroy }
    respond_to do |format|
      format.html { redirect_to instructors_url, notice: 'Instructor was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_instructor
      @instructor = Instructor.find(params[:id])
    end

    def set_current_user
      @current_user = current_user.username
    end
    
    # Never trust parameters from the scary internet, only allow the white list through.
    def instructor_params
      params.require(:instructor).permit(:name, :nick, :capacity, :program_ids => [])
    end
end
