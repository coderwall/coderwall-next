ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "clearance/test_unit"

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
end
