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

class Operation < ActiveRecord::Base
  after_initialize :build_detail

  belongs_to :event
  belongs_to :operation_type
  belongs_to :device
  delegate :name, to: :device, prefix: :device, allow_nil: true
  delegate :description, to: :operation_type, prefix: :operation_type, allow_nil: true

  has_one :operation_detail
  delegate :request, :result_status, :request=, :send_request, :response, to: :operation_detail, allow_nil: true

  validates :operation_type, presence: true
  validates :device, presence: true, allow_nil: true

  private 
    def build_detail
      if self.operation_detail.nil? && self.device.present? && self.operation_type.present?
        self.build_operation_detail(uri: self.device.uri, method: self.operation_type.method, request: self.operation_type.request_body) 
      end
    end

end
