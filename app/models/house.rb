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

class House < ActiveRecord::Base
  self.primary_key = :hgw_id

  has_many :users
  has_many :rooms
  accepts_nested_attributes_for :rooms, allow_destroy: true, reject_if: :all_blank

  validates :name, presence: true
  validates :hgw_id, presence: true
#  validates :ip_address, presence: true, format: { with: Resolv::IPv4::Regex }

  def endpoint
    HGW_ENDPOINT_TEMPLATE % { ip_address: ip_address } << hgw_id << "/"
  end

  def self.ip_addresses
    return House.all.pluck(:ip_address).uniq
  end

end
