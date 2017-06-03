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

require 'test_helper'

class EButtonTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
