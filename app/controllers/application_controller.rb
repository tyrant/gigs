class ApplicationController < ActionController::API
  include JSONAPI::ActsAsResourceController

  def base_url
    ''
  end
end
