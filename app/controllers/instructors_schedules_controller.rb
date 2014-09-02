class InstructorsSchedulesController < ApplicationController
  before_action :set_instructors_schedule, only: [:show, :edit, :update, :destroy]

  # GET /instructors_schedules
  # GET /instructors_schedules.json
  def index
    @instructors_schedules = InstructorsSchedule.all
  end

  # GET /instructors_schedules/1
  # GET /instructors_schedules/1.json
  def show
  end

  # GET /instructors_schedules/new
  def new
    @instructors_schedule = InstructorsSchedule.new
  end

  # GET /instructors_schedules/1/edit
  def edit
  end

  # POST /instructors_schedules
  # POST /instructors_schedules.json
  def create
    @instructors_schedule = InstructorsSchedule.new(instructors_schedule_params)

    respond_to do |format|
      if @instructors_schedule.save
        format.html { redirect_to @instructors_schedule, notice: 'Instructors schedule was successfully created.' }
        format.json { render :show, status: :created, location: @instructors_schedule }
      else
        format.html { render :new }
        format.json { render json: @instructors_schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /instructors_schedules/1
  # PATCH/PUT /instructors_schedules/1.json
  def update
    respond_to do |format|
      if @instructors_schedule.update(instructors_schedule_params)
        format.html { redirect_to @instructors_schedule, notice: 'Instructors schedule was successfully updated.' }
        format.json { render :show, status: :ok, location: @instructors_schedule }
      else
        format.html { render :edit }
        format.json { render json: @instructors_schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /instructors_schedules/1
  # DELETE /instructors_schedules/1.json
  def destroy
    @instructors_schedule.destroy
    respond_to do |format|
      format.html { redirect_to instructors_schedules_url, notice: 'Instructors schedule was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_instructors_schedule
      @instructors_schedule = InstructorsSchedule.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def instructors_schedule_params
      params.require(:instructors_schedule).permit(:schedule_id, :instructor_id, :day, :avail_seat)
    end
end
