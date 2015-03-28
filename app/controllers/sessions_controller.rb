class SessionsController < ApplicationController
  def new
  end

  def create
    # check info about params[:session][:email] and params[:session][:password]
    # https://www.railstutorial.org/book/log_in_log_out#fig-initial_failed_login_rails_3
    user = User.find_by(email: params[:session][:email].downcase)

    # "authenticate" method provided by has_secure_password  in User Model
    if user && user.authenticate(params[:session][:password])
      # log_id method defined in sessions_helper
      log_in(user)
      # if the checkbox is checked, remember the user
      # remember method defined in sessions_helper
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      redirect_to user

    else
      # flash.now, is specifically designed for displaying flash messages on rendered pages. Unlike the contents of flash, the contents of flash.now disappear as soon as there is an additional request
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    # log_out method is defined in sessions_helper
    log_out if logged_in?
    redirect_to root_url
  end

end
