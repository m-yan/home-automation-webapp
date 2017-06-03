# == Schema Information
#
# Table name: devices
#
#  id         :integer          not null, primary key
#  house_id   :string
#  room_id    :integer
#  note       :string
#  id_at_hgw  :string
#  type       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_devices_on_house_id   (house_id)
#  index_devices_on_id_at_hgw  (id_at_hgw)
#  index_devices_on_room_id    (room_id)
#  index_devices_on_type       (type)
#

class Device < ActiveRecord::Base
  scope :nearby, ->(device) { where(room: device.room) }
  scope :owned_by, ->(user) { where(house: user.house) }

  belongs_to :house
  delegate :hgw_id, :endpoint, to: :house

  belongs_to :room

  has_one :status, class_name: :DeviceStatus

  validates :house, presence: true
  validates :room, presence: true
  validates :id_at_hgw, presence: true
  validates :type, presence: true

  def name
    label = DEVICE_TYPES.key(self.type).to_s.split("(")[0] << "(" << room.to_s
    label <<  "_" << note if note.present?
    label << ")"
    return label
  end

  def location
    location = room.to_s
    location <<  "(" << note << ")" if note.present?
    return location
  end

  def uri
    endpoint << id_at_hgw 
  end 

  def build_remote_device
    RemoteDevice.new(self)
  end
end
