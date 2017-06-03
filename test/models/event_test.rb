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

require 'test_helper'

class EventTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
