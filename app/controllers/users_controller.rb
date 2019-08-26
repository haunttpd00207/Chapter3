class UsersController < ApplicationController
  before_action :load_user, only: [:show, :edit, :update, :destroy]
	before_action :logged_in_user, only: [:index, :edit, :update]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy]
  
  def show
    redirect_to root_path and return unless @user.activated?
  end

  def index
    @users = User.where(activated: true).paginate(page: params[:page], per_page: 8) 
  end

  def new
  	@user = User.new
  end

  def edit

  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render :new
    end
  end

  def update
    if @user.update_attributes(user_params)  #return TRUE if update successful
      #success show here
      flash[:success] = "Updating are successful!"
      redirect_to @user
    else
      #unsuccess show here
      render :edit  # render a edit VIEWS
    end
  end

  def destroy
    @user.destroy
    flash[:success] = "Users Deleted!"
    redirect_to users_path
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end

    def logged_in_user
      return if logged_in?
 
      store_location
      flash[:danger] = "Please log in!"
      redirect_to login_path
    end

    def correct_user
      #@user =  User.find(params[:id])
      redirect_to root_path unless current_user?(@user)
    end

    def load_user
      @user = User.find_by id: params[:id]
      return if @user
      flash[:danger] = "Undefined User!"
      redirect_to root_path
    end

    def admin_user
      redirect_to root_path unless current_user.admin?
    end

end
 