# == Schema Information
#
# Table name: operation_types
#
#  id           :integer          not null, primary key
#  description  :string
#  device_type  :string
#  method       :string
#  modules_body :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_operation_types_on_device_type  (device_type)
#

require 'test_helper'

class OperationTypeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
