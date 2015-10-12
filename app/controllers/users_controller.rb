class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :set_instructor, only: [:show, :edit, :update, :destroy]
  before_action :set_instructor_options

  # before_action :authorize_admin
  filter_resource_access
  
  # GET /users
  # GET /users.json
  def index
    @users = User.order(:username)
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:group_id, :username, :fullname, :password,
                                   :password_confirmation, :email).tap do |whitelisted|
                                      if params[:instructor_id]
                                        if params[:instructor_id].empty?
                                          whitelisted[:instructor] = nil
                                        else
                                          whitelisted[:instructor] = Instructor.find(params[:instructor_id])
                                        end
                                      end
                                    end
    end

    def set_instructor
      if @user
        @instructor = UsersInstructor.find_by(user: @user).instructor rescue nil
      end
    end

    def set_instructor_options
      linked_instructors = UsersInstructor.all.map {|e| e.instructor_id}
      @instructor_options = Instructor.all.map {|e| [e.nick, e.id]}
      @instructor_options_disabled = linked_instructors
    end
end
