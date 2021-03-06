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

class MSensor < Device
  has_one :status, class_name: :MSensorStatus, foreign_key: :device_id
  delegate :enabled, :detected, to: :status, allow_nil: true
end
