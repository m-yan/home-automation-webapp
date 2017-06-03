# == Schema Information
#
# Table name: rooms
#
#  id            :integer          not null, primary key
#  house_id      :string
#  floor         :string
#  facility_type :string
#  note          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_rooms_on_house_id  (house_id)
#

require 'test_helper'

class RoomTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
