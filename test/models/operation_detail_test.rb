# == Schema Information
#
# Table name: operation_details
#
#  id            :integer          not null, primary key
#  operation_id  :integer
#  uri           :string
#  method        :string
#  request       :text
#  result_status :string
#  response      :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_operation_details_on_operation_id  (operation_id)
#

require 'test_helper'

class OperationDetailTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
