# frozen_string_literal: true

module Callable
  PARAM_REQUIRED = Object.new.freeze

  def self.included(mod) = mod.extend(ClassMethods)

  module ClassMethods
    def call(**args, &block)
      new(**args, &block).call
    end

    def params = @params ||= { args: {}, required: [] }

    def param(key, default: PARAM_REQUIRED)
      params[:args][key] = default
      params[:required] << key if PARAM_REQUIRED.equal?(default)

      attr_reader key
    end
  end

  def initialize(**kwargs)
    params = self.class.params

    missing = params[:required] - kwargs.keys
    raise ArgumentError, "missing keywords: #{missing.map(&:inspect).join(", ")}" if missing.present?

    unknown = kwargs.keys - params[:args].keys
    raise ArgumentError, "unknown keywords: #{unknown.map(&:inspect).join(", ")}" if unknown.present?

    params[:args].map do |key, default|
      value = if kwargs.has_key?(key)
        kwargs[key]
      elsif default.is_a?(Proc)
        instance_exec(&default)
      else
        default
      end

      instance_variable_set(:"@#{key}", value)
    end
  end
end
