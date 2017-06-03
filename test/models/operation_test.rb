# == Schema Information
#
# Table name: operations
#
#  id                :integer          not null, primary key
#  event_id          :integer
#  device_id         :integer
#  operation_type_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_operations_on_device_id          (device_id)
#  index_operations_on_event_id           (event_id)
#  index_operations_on_operation_type_id  (operation_type_id)
#

require 'test_helper'

class OperationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
