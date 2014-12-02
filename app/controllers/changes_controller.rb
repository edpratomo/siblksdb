class ChangesController < ApplicationController
  before_action :set_change, only: [:show]
  # before_action :authorize_sysadmin
  filter_resource_access

  helper_method :sort_column, :sort_direction

  # GET /changes
  # GET /changes.json
  def index
    # @changes = Change.all
    @changes = Change.order(sort_column + ' ' + sort_direction).paginate(:per_page => 10, :page => params[:page]) 
  end

  # GET /changes/1
  # GET /changes/1.json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_change
      @change = Change.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def change_params
      params.require(:change).permit(:table_name, :action_tstamp, :action, :original_data, :new_data, :query, :modified_by)
    end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ?  params[:direction] : "desc"
  end
  
  def sort_column
    Change.column_names.include?(params[:sort]) ? params[:sort] : "action_tstamp"
  end

end
