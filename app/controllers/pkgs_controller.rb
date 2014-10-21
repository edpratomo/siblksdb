class PkgsController < ApplicationController
  before_action :set_pkg, only: [:show, :edit, :update, :destroy]
  before_action :authorize_sysadmin, only: [:new, :create, :edit, :update, :destroy]

  # GET /pkgs
  # GET /pkgs.json
  def index
    @pkgs = Pkg.order(:program_id, :pkg, :level)
  end

  # GET /pkgs/1
  # GET /pkgs/1.json
  def show
  end

  # GET /pkgs/new
  def new
    @pkg = Pkg.new
  end

  # GET /pkgs/1/edit
  def edit
  end

  # POST /pkgs
  # POST /pkgs.json
  def create
    @pkg = Pkg.new(pkg_params)

    respond_to do |format|
      if @pkg.save
        format.html { redirect_to @pkg, notice: 'Pkg was successfully created.' }
        format.json { render :show, status: :created, location: @pkg }
      else
        format.html { render :new }
        format.json { render json: @pkg.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pkgs/1
  # PATCH/PUT /pkgs/1.json
  def update
    respond_to do |format|
      if @pkg.update(pkg_params)
        format.html { redirect_to @pkg, notice: 'Pkg was successfully updated.' }
        format.json { render :show, status: :ok, location: @pkg }
      else
        format.html { render :edit }
        format.json { render json: @pkg.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pkgs/1
  # DELETE /pkgs/1.json
  def destroy
    @pkg.destroy
    respond_to do |format|
      format.html { redirect_to pkgs_url, notice: 'Pkg was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pkg
      @pkg = Pkg.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def pkg_params
      params.require(:pkg).permit(:pkg, :program_id, :level)
    end
end
