class GradeSheetsController < ApplicationController
  before_action :set_grade_sheet, only: [:show, :edit, :update, :destroy]

  # GET /grade_sheets
  # GET /grade_sheets.json
  def index
    @grade_sheets = GradeSheet.all
  end

  # GET /grade_sheets/1
  # GET /grade_sheets/1.json
  def show
  end

  # GET /grade_sheets/new
  def new
    @grade_sheet = GradeSheet.new
  end

  # GET /grade_sheets/1/edit
  def edit
  end

  # POST /grade_sheets
  # POST /grade_sheets.json
  def create
    @grade_sheet = GradeSheet.new(grade_sheet_params)

    respond_to do |format|
      if @grade_sheet.save
        format.html { redirect_to @grade_sheet, notice: 'Grade sheet was successfully created.' }
        format.json { render :show, status: :created, location: @grade_sheet }
      else
        format.html { render :new }
        format.json { render json: @grade_sheet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /grade_sheets/1
  # PATCH/PUT /grade_sheets/1.json
  def update
    respond_to do |format|
      if @grade_sheet.update(grade_sheet_params)
        format.html { redirect_to @grade_sheet, notice: 'Grade sheet was successfully updated.' }
        format.json { render :show, status: :ok, location: @grade_sheet }
      else
        format.html { render :edit }
        format.json { render json: @grade_sheet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /grade_sheets/1
  # DELETE /grade_sheets/1.json
  def destroy
    @grade_sheet.destroy
    respond_to do |format|
      format.html { redirect_to grade_sheets_url, notice: 'Grade sheet was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_grade_sheet
      @grade_sheet = GradeSheet.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def grade_sheet_params
      params[:grade_sheet]
    end
end
