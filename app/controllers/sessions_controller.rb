class SessionsController < ApplicationController
  skip_before_action :authenticate_user_by_token, only: [:create]

  def create
    user = User.find_by(email: login_params[:email])

    if user && user.valid_password?(login_params[:password])
      auth_token = AuthTokenService.new(user).generate_tokens
      user.current_auth_token = auth_token

      render json: CreatedUserSerializer.new(user).as_json, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  private

  def login_params
    params.permit(:email, :password)
  end
end
  