class Micropost < ApplicationRecord
  belongs_to :user
  default_scope -> { order(created_at: :desc) }
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :in_reply_to,length: {maximum: 21}
  before_save :reply_user

  def reply_user
    if reply_name = content.match(/(@[\w+\-]+)\s.*/i)
      self.in_reply_to = reply_name[1]
    end
  end
  
end
