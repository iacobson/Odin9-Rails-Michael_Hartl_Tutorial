module SessionsHelper

  # make the SessionsHelper content available in all views by including it in the ApplicationController

  # Logs in the given user.
  def log_in(user)
    session[:user_id] = user.id
  end

  # Remembers a user in a persistent session.
  def remember(user)
    # remember defined in the User model
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # create a current_user method, to be available in all controllers and views
  # the "@current_user ||=" ensures that the db will be queried ONLY ONCE. Find the user ONLY if @current_user is nil
  # using find_by, as find will rise exception is id is not found. find_by returns nil if id is not found
  # check details here: https://www.railstutorial.org/book/log_in_log_out#sec-current_user
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # Returns true if the given user is the current user.
  def current_user?(user)
    user == current_user
  end


  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    !current_user.nil?
  end

  # Forgets a persistent session.
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # Logs out the current user.
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  # Redirects to stored location (or to the default)
  # Needed to redirect users after login to the pagin they initially requested before login
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # Stores the URL trying to be accessed
  def store_location
    # puts the requested URL in the session variable under the key :forwarding_url, but only for a GET request
    session[:forwarding_url] = request.url if request.get?
  end

end
