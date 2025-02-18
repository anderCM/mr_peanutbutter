class RegistrationsController < ApplicationController
  skip_before_action :authenticate_user_by_token, only: [ :create ]

  def create
    user = User.new(user_params)

    if user.save
      auth_token_service = AuthTokenService.new(user).generate_tokens
      user.current_auth_token = auth_token_service
      WelcomeUserService.new(user).process

      render json: CreatedUserSerializer.new(user).as_json, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end
end
