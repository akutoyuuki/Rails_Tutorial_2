class UsersController < ApplicationController
  before_action :logged_in_check, only: [:index, :edit, :update, :destroy, :following, :followers]
  before_action :correct_user_check, only: [:edit, :update]
  before_action :admin_or_myself_check, only: :destroy

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
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "プロフィールを変更しました"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    if User.find(params[:id]).destroy
      flash[:success] = "アカウントを削除しました"
    else
      flash[:success] = "アカウント削除に失敗しました"
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
    def correct_user_check
      @user ||= User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    #管理者または自身であるかどうか確認
    def admin_or_myself_check
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user.admin? || current_user?(@user)
    end
end
