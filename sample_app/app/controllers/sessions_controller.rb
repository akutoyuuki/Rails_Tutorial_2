class SessionsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by!(email: params[:session][:email].downcase)
    if @user.authenticate(params[:session][:password])
      if @user.activated?
        log_in @user
        params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
        redirect_back_or @user
      else
        message = "アカウントが有効ではありません"
        message += "有効化用メールを確認してください"
        flash[:warning] = message
        redirect_to root_url
      end
    else
      flash.now[:danger] = 'パスワードが正しくありません'
      render :new
    end
  rescue ActiveRecord::RecordNotFound => e
    flash.now[:danger] = "メールアドレスが正しくありません"
    render :new
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
  
end
