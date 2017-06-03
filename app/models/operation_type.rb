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

class OperationType < ActiveRecord::Base
  has_and_belongs_to_many :remote_buttons

  validates :device_type, presence: true, inclusion: { in: DEVICE_TYPES.values } 
  validates :method, inclusion: { in: %w(post get) }, allow_nil: true

  def request_body
    template = REQUEST_XML_TEMPLATE
    return modules_body ? template % { modules_body: self[:modules_body] } : nil
  end

end
