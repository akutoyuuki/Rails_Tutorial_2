class User < ApplicationRecord
    has_many :microposts, dependent: :destroy
    has_many :active_relationships, class_name: :Relationship, foreign_key: :follower_id, dependent: :destroy
    has_many :passive_relationships, class_name: :Relationship, foreign_key: :followed_id, dependent: :destroy
    has_many :following, through: :active_relationships, source: :followed
    has_many :followers, through: :passive_relationships, source: :follower
    attr_accessor :remember_token, :activation_token, :reset_token
    before_save :downcase_email
    before_create :create_activation_digest
    validates :name, presence: true, length: { maximum: 50 }
    validates :email, presence: true, length: { maximum: 255 }, email_format: true, uniqueness: { case_sensitive: false }
    has_secure_password
    validates :password, presence: true, length: { minimum: 6}
    validates :user_name, presence: true, length: { maximum: 20 }, user_name_format: true, uniqueness: { case_sensitive: false }

    #渡された文字列のハッシュ値を返す
    def change_digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
    end

    #ランダムなトークンを返す
    def new_token
        SecureRandom.urlsafe_base64
    end

    #永続セッションのためにユーザーをデータベースに記憶する
    def remember
        self.remember_token = new_token
        update_attribute(:remember_digest, change_digest(remember_token))
    end

    #渡されたトークンがダイジェストと一致したらtrueを返す
    def authenticated?(attribute, token)
        digest = send("#{attribute}_digest")
        return false if digest.nil?
        BCrypt::Password.new(digest).is_password?(token)
    end

    #ユーザーのログイン情報を破棄する
    def forget
        update_attribute(:remember_digest, nil)
    end

    #アカウントを有効にする
    def activate
        update_columns(activated: true, activated_at: Time.zone.now)
    end

    #有効化用のメールを送信する
    def send_activation_email
        UserMailer.account_activation(self).deliver_now
    end

    #パスワード再設定の属性を設定する
    def create_reset_digest
        self.reset_token = new_token
        update_columns(reset_digest: change_digest(reset_token), reset_sent_at: Time.zone.now)
    end

    #パスワード再設定のメールを送信する
    def send_password_reset_email
        UserMailer.password_reset(self).deliver_now
    end

    #パスワード再設定の期限が切れている場合はtrueを返す
    def password_reset_expired?
        reset_sent_at < 2.hours.ago
    end

    #タイムラインデータの検索
    def feed
        following_ids = "SELECT followed_id FROM relationships WHERE follower_id = :user_id"
        Micropost.where("in_reply_to = :reply OR user_id IN (#{following_ids}) OR user_id = :user_id",reply: "@#{user_name}", user_id: id)
    end

    #ユーザーをフォローする
    def follow(other_user)
        following << other_user
    end

    #ユーザーをフォロー解除する
    def unfollow(other_user)
        active_relationships.find_by(followed_id: other_user.id).destroy
    end

    #現在のユーザーがフォローしてたらtrueを返す
    def is_following?(other_user)
        following.include?(other_user)
    end

    private
        #メールアドレスをすべて小文字にする
        def downcase_email
            email.downcase!
        end

        #有効化トークンとダイジェストを作成及び代入する
        def create_activation_digest
            self.activation_token = new_token
            self.activation_digest = change_digest(activation_token)
        end
end