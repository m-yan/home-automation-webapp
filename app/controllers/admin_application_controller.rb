class AdminApplicationController < ApplicationController
  before_action :user_has_role_admin?
end
