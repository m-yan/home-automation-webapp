# == Schema Information
#
# Table name: device_statuses
#
#  id               :integer          not null, primary key
#  device_id        :integer
#  type             :string
#  mode             :integer          default(1)
#  temperature      :float            default(25.0)
#  power            :boolean          default(FALSE)
#  volume           :integer          default(0)
#  on_timer         :boolean          default(FALSE)
#  start_time       :datetime
#  on_timer_job_id  :string
#  off_timer        :boolean          default(FALSE)
#  stop_time        :datetime
#  off_timer_job_id :string
#  humidity         :integer          default(60)
#  opened           :boolean          default(FALSE)
#  enabled          :boolean          default(TRUE)
#  illuminance      :integer          default(1000)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_device_statuses_on_device_id  (device_id)
#

require 'test_helper'

class ThSensorStatusTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
