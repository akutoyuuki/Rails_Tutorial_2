class AccountActivationsController < ApplicationController

    def edit
        user = User.find_by!(email: params[:email])
        if !user.activated? && user.authenticated?(:activation, params[:id])
            user.activate
            log_in user
            flash[:success] = "アカウント認証に成功しました!"
            redirect_to user
        else
            flash[:danger] = "無効なリンクです。有効期限が切れている可能性があります。"
            redirect_to root_url
        end
    rescue ActiveRecord::RecordNotFound => e
        flash[:danger] = "無効なメールアドレスです"
        redirect_to root_url
    end
end
