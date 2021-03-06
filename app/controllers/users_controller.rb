class UsersController < ApplicationController
  # logged_in_user method defined below in the privates methods
  before_action :logged_in_user, only: [:edit, :update, :index, :destroy, :following, :followers]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy]

  def index
    # all users except current user
    @users = User.where.not(id: current_user.id).where(activated: true).paginate(page: params[:page])
    #debugger
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      # send activation mail
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render 'new'
    end
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])

    # relationship follow/unfollow
    if current_user
      if current_user.following?(@user)
        @relationship = current_user.active_relationships.find_by(followed_id: @user.id)
      else
        @relationship = current_user.active_relationships.build
      end
    end

  end

  def edit
    @user = User.find(params[:id])

  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_path
  end

  def following
    @title = "Following"
    @user  = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user  = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  private

    def user_params
      # for security reasons, "admin" attribute is not available in the permint. Admin will be assigned through console
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    # BEFORE FILTERS:
    # 1. Confirms a logged-in user.
    # logged_in_user - moved to application_controller in order to be accessible in all controllers


    # 2. Confirms the correct user (user passed in the params is the same as logged in user - needed for edit/update security)
    def correct_user
      @user = User.find(params[:id])
      # redirect to root if the user id is not the same as logged in user
      # "current_user?" method is defined in the sessions_helper
      redirect_to(root_url) unless current_user?(@user)
    end

    # 3. Confirm that the user is "admin", otherwise redirect to root - needed just for deleting users
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end

end
