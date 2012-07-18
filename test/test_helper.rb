ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "capybara/rails"
require 'mocha'

module ActionController
  class TestCase
    include Capybara::DSL
  end
end

class ActiveSupport::TestCase

  self.use_transactional_fixtures = true
  fixtures :all

  def raw_post(action, params, body)
    @request.env['RAW_POST_DATA'] = body
    response = post(action, params)
    @request.env.delete('RAW_POST_DATA')
    response
  end
end

