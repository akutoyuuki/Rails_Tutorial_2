class MicropostsController < ApplicationController
    before_action :logged_in_check, only: [:create, :destroy]
    before_action :post_check, only: :destroy

    def index
        redirect_to root_url
    end

    def create
        @micropost = current_user.microposts.build(micropost_params)
        if @micropost.save
            flash[:success] = "投稿しました!"
            redirect_to root_url
        else
            render 'static_pages/home'
        end
    end

    def destroy
        if @micropost.destroy
            flash[:success] = "投稿を1件削除しました"
        else
            flash[:danger] = "投稿の削除に失敗しました"
        end
        redirect_back(fallback_location: root_url)
    end

    private
        def micropost_params
            params.require(:micropost).permit(:content, :picture, :in_reply_to)
        end

        def post_check
            @micropost ||= current_user.microposts.find_by(id: params[:id])
            redirect_to root_url if @micropost.nil?
        end
end
