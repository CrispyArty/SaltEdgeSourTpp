# frozen_string_literal: true

module ErrorHandlingConcern
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity_response

    rescue_from NotAuthorizedError, with: :render_forbidden_response
  end

  private

  def render_unprocessable_entity_response(exception)
    @errors = exception.respond_to?(:record) ? exception.record.errors : []
    render 'api/v1/application/errors/unprocessable_entity', status: :unprocessable_entity
  end


  def render_forbidden_response(exception)
    @exception = exception
    render 'api/v1/application/errors/forbidden', status: :forbidden
  end

  # # Workaround: https://github.com/rails/rails/issues/38285#issuecomment-806231980
  # def process_action(*args)
  #   super
  # rescue ActionDispatch::Http::Parameters::ParseError
  #   render 'api/v1/application/errors/bad_request', status: :bad_request
  # end
end
