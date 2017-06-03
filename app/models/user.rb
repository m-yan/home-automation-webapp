# == Schema Information
#
# Table name: users
#
#  id                  :integer          not null, primary key
#  login_id            :string
#  name                :string
#  email               :string           default(""), not null
#  encrypted_password  :string           default(""), not null
#  remember_created_at :datetime
#  failed_attempts     :integer          default(0), not null
#  unlock_token        :string
#  locked_at           :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  house_id            :string
#
# Indexes
#
#  index_users_on_email     (email) UNIQUE
#  index_users_on_house_id  (house_id)
#  index_users_on_login_id  (login_id) UNIQUE
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  #devise :database_authenticatable, :registerable,
  #       :recoverable, :rememberable, :trackable, :validatable
  #devise :database_authenticatable, :registerable, :rememberable, :validatable , :timeoutable
  devise :database_authenticatable, :registerable, :rememberable, :validatable, :lockable
  
  has_and_belongs_to_many :roles
  belongs_to :house
  has_many :notifications

  validates :login_id, presence: true, uniqueness: true
  validates :name, presence: true
  validates :house, presence: true, on: :create

  def has_role?(name)
    self.roles.where(name: name).length > 0
  end

end
