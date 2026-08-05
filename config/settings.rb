# frozen_string_literal: true

class Settings
  attr_reader :config

  def initialize(config)
    @config = config
  end

  def [](key)
    return send(key) if respond_to?(key)
    config[key]
  end

  def ob_callback_url
    Rails.application.routes.url_helpers.success_api_callback_url
  end
end
