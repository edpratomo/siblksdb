class ProgramsInstructorsController < ApplicationController
  before_action :set_programs_instructor, only: [:show, :edit, :update, :destroy]

  # GET /programs_instructors
  # GET /programs_instructors.json
  def index
    @programs_instructors = ProgramsInstructor.all
  end

  # GET /programs_instructors/1
  # GET /programs_instructors/1.json
  def show
  end

  # GET /programs_instructors/new
  def new
    @programs_instructor = ProgramsInstructor.new
  end

  # GET /programs_instructors/1/edit
  def edit
  end

  # POST /programs_instructors
  # POST /programs_instructors.json
  def create
    @programs_instructor = ProgramsInstructor.new(programs_instructor_params)

    respond_to do |format|
      if @programs_instructor.save
        format.html { redirect_to @programs_instructor, notice: 'Programs instructor was successfully created.' }
        format.json { render :show, status: :created, location: @programs_instructor }
      else
        format.html { render :new }
        format.json { render json: @programs_instructor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /programs_instructors/1
  # PATCH/PUT /programs_instructors/1.json
  def update
    respond_to do |format|
      if @programs_instructor.update(programs_instructor_params)
        format.html { redirect_to @programs_instructor, notice: 'Programs instructor was successfully updated.' }
        format.json { render :show, status: :ok, location: @programs_instructor }
      else
        format.html { render :edit }
        format.json { render json: @programs_instructor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /programs_instructors/1
  # DELETE /programs_instructors/1.json
  def destroy
    @programs_instructor.destroy
    respond_to do |format|
      format.html { redirect_to programs_instructors_url, notice: 'Programs instructor was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_programs_instructor
      @programs_instructor = ProgramsInstructor.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def programs_instructor_params
      params.require(:programs_instructor).permit(:program_id, :instructor_id)
    end
end
