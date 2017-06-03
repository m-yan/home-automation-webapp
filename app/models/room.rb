# == Schema Information
#
# Table name: rooms
#
#  id            :integer          not null, primary key
#  house_id      :string
#  floor         :string
#  facility_type :string
#  note          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_rooms_on_house_id  (house_id)
#

class Room < ActiveRecord::Base
  belongs_to :house
  has_many :devices

  validates :floor, presence: true#, inclusion: { in: %w(living dining entrance kitchen room bathroom toilet) }
  validates :facility_type, presence: true#, inclusion: { in: %w(1F 2F 3F B1) } 

  def to_s
    #label = floor + " " + facility_type 
    #label << " " << note unless note.blank?
    #return label
    note.presence || floor + " " + facility_type
  end
end

