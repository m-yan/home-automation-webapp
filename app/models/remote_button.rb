# == Schema Information
#
# Table name: remote_buttons
#
#  id         :integer          not null, primary key
#  note       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class RemoteButton < ActiveRecord::Base
  has_and_belongs_to_many :operation_types,  ->{order("id desc") }
end
