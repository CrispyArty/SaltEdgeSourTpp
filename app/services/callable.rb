# frozen_string_literal: true

module Callable
  def call(**args, &block)
    new(**args, &block).call
  end
end
