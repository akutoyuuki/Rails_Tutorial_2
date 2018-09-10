class PasswordResetsController < ApplicationController
  before_action :check_expiration, only: [:edit, :update]

  def new
  end

  def create
    @user = User.find_by!(email: params[:password_reset][:email].downcase)
    @user.create_reset_digest
    @user.send_password_reset_email
    flash[:info] = "パスワードの再設定に関するメールを送信しました！"
    redirect_to root_url
  rescue ActiveRecord::RecordNotFound => e
    flash.now[:danger] = "メールアドレスが間違っています"
    render :new
  end
  
  def edit
    redirect_to root_url and return unless user_valid?
  end

  def update
    redirect_to root_url and return unless user_valid?
    if user.update_attributes(user_params)
      log_in user
      user.update_attribute(:reset_digest, nil)
      flash[:success] = "パスワードが再設定されました"
      redirect_to user
    else
      render :edit
    end
  end

  private
    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    def user
      @user ||= User.find_by!(email: params[:email])
    end

    #正しいユーザーかどうか確認する
    def user_valid?
      user.activated? && user.authenticated?(:reset, params[:id])
    end

    #トークンが期限切れかどうか確認する
    def check_expiration
      if user.password_reset_expired?
        flash[:danger] = "再設定用のリンクの期限が切れています。もう一度送信しなおしてください"
        redirect_to new_password_reset_url
      end
    rescue ActiveRecord::RecordNotFound => e
      redirect_to root_url
    end
end
