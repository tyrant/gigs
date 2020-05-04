JSONAPI.configure do |config|
  config.resource_cache = Rails.cache

  # v0.10 and later
  # config.default_caching = true

  config.default_paginator = :paged
  config.default_page_size = 20
  config.maximum_page_size = 100
end