class AccountActivationsController < ApplicationController

  def edit
    user = User.find_by(email: params[:email])
    # if there is a user found by that mail
    # if the user was NOT already activated
    # and the user is authentificated
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      # activate method is defined in the User Model
      user.activate
      log_in user
      flash[:success] = "Account activated!"
      redirect_to user
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end

end
