class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # make the SessionsHelper content available in all views by including it in the ApplicationController
  include SessionsHelper
end
