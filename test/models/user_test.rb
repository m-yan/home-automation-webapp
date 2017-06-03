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

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
