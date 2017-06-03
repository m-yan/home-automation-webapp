# == Schema Information
#
# Table name: houses
#
#  hgw_id     :string           not null, primary key
#  name       :string
#  ip_address :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_houses_on_hgw_id  (hgw_id) UNIQUE
#

require 'test_helper'

class HouseTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
