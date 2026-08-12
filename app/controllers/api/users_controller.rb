module Api
  class UsersController < ActionController::API
    # allow_browser versions: :modern

    def index
      render json: { status: "OK" }
    end

    def show
      render json: { params: params }
    end

    def create
      render json: { method: "POST", params: params }
    end

    private

    def user_params
      # This looks for the 'user' key that Rails automatically created for you
      params.expect(user: [ :name, :email1 ])
    end
  end
end
