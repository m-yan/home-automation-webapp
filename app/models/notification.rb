# == Schema Information
#
# Table name: notifications
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  message       :text
#  detect_device :string
#  read          :boolean          default(FALSE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_notifications_on_user_id  (user_id)
#

class Notification < ActiveRecord::Base
  belongs_to :user

  validates :user, presence: true
  validates :message, presence: true
  

end
