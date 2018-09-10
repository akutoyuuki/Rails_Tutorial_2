class UsersController < ApplicationController
  before_action :check_logged_in, only: [:index, :edit, :update, :destroy, :following, :followers]

  def index
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
    redirect_to root_url and return unless @user.activated?
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "アカウント認証用のメールを送信しました"
      redirect_to root_url
    else
      render :new
    end
  end

  def edit
    redirect_to root_url and return unless is_correct_user?
  end

  def update
    redirect_to root_url and return unless is_correct_user?
    if @user.update_attributes(user_params)
      flash[:success] = "プロフィールを変更しました"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    user = User.find(params[:id])
    if current_user.admin? || current_user?(user)
      if user.destroy
        flash[:success] = "アカウントを削除しました"
      else
        flash[:success] = "アカウント削除に失敗しました"
      end
    end
    redirect_to root_url
  end

  def following
    @title = "フォロー"
    @user ||= User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render :following
  end

  def followers
    @title = "フォロワー"
    @user ||= User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render :followers
  end

  private
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :user_name)
    end

    #正しいユーザーかどうか確認
    def is_correct_user?
      @user ||= User.find(params[:id])
      current_user?(@user)
    end
end
