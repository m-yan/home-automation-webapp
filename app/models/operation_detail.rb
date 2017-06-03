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

class OperationDetail < ActiveRecord::Base
  belongs_to :operation

  validates :uri, presence: true
  validates :method, presence: true, inclusion: { in: %w(post get) }

  def send_request
    requestor = HgwIfRequestor.new(self.uri, self.method, self.request)
    ret = requestor.send_request

    self.result_status = requestor.result_status
    self.response = requestor.response

    return ret
  end

  def pre_formatted_response 
    ret = Nokogiri::XML(self[:response])
    case ret.to_s
    when /Device/
      return ret
    else
      return nil
    end
  end
end
