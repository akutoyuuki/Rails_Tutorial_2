class Micropost < ApplicationRecord
  belongs_to :user
  default_scope -> { order(created_at: :desc) }
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :in_reply_to,length: {maximum: 21}
  before_save :reply_user
  scope :including_replies, ->(user){where("in_reply_to = ? OR in_reply_to = ? OR user_id = ?","","@#{user.user_name}",user.id)}

  def reply_user
    if reply_name = content.match(/(@[\w+\-]+)\s.*/i)
      self.in_reply_to = reply_name[1]
    end
  end

  def self.followed_by(user)
    following_ids = "SELECT followed_id FROM relationships WHERE follower_id = :user_id"
    Micropost.where("in_reply_to = :reply OR user_id IN (#{following_ids}) OR user_id = :user_id",reply: "@#{user.user_name}", user_id: user.id)
  end
end
