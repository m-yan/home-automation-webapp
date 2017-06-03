# == Schema Information
#
# Table name: events
#
#  id            :integer          not null, primary key
#  house_id      :string
#  user_id       :integer
#  device_id     :integer
#  event_type_id :integer
#  occurred_at   :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_events_on_device_id      (device_id)
#  index_events_on_event_type_id  (event_type_id)
#  index_events_on_house_id       (house_id)
#  index_events_on_user_id        (user_id)
#

class Event < ActiveRecord::Base
  before_create :record_occurred_at

  scope :owned_by, ->(user) { where(['user_id = ? or ( house_id = ? and user_id is null )', user, user.house]) }

  belongs_to :house
  delegate :name, to: :house, prefix: :house, allow_nil: true

  belongs_to :user
  delegate :name, :login_id, to: :user, prefix: :user, allow_nil: true  

  belongs_to :device
  delegate :name, to: :device, prefix: :device, allow_nil: true

  belongs_to :event_type
  delegate :description, to: :event_type, prefix: :event_type, allow_nil: true

  has_many :operations,  ->{order("id") }

  alias_attribute :hgw_id, :house_id

  validates :house, presence: true
  validates :user, presence: true, allow_nil: true
  validates :device, presence: true, allow_nil: true
  validates :event_type, presence: true

  def record_occurred_at
    self[:occurred_at] = self[:occurred_at] || Time.current
  end

  def self.build_by_user(user)
    return Event.new(house: user.house, user: user)
  end
end
