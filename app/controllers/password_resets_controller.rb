class PasswordResetsController < ApplicationController
  skip_before_action :authorize

  layout 'password_resets.html.erb'

  def create
    user = User.find_by_email(params[:email])
    
    unless user
      redirect_to new_password_reset_path, alert: "Tidak ditemukan user dengan alamat email #{params[:email]}"
    else
      user.send_password_reset
      redirect_to new_password_reset_path, :notice => "Email sent with password reset instructions. Check your spam folder."
    end
  end

  def edit
    @user = User.find_by_password_reset_token!(params[:id])
  end

  def update
    @user = User.find_by_password_reset_token!(params[:id])
    if @user.password_reset_sent_at < 2.hours.ago
      redirect_to new_password_reset_path, :alert => "Password reset has expired."
    elsif @user.update_attributes(user_params)
      redirect_to root_url, :notice => "Password has been reset."
    else
      render :edit
    end
  end

  def user_params
    params.require(:user).permit(:fullname, :password, :password_confirmation, :email)
  end

end
