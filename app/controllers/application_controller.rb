class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # make the SessionsHelper content available in all views by including it in the ApplicationController
  include SessionsHelper


  private

    # Confirms a logged-in user.
    def logged_in_user
      # logged_in? defined in sessions_helper
      unless logged_in?
        store_location # method defined in sessions_helper to store the requested url
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end


end
