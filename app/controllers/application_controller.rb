class ApplicationController < ActionController::API
  # Validations
  before_action :authenticate_user_by_token

  # Error handlers
  rescue_from ActionController::ParameterMissing, with: :parameter_missing
  rescue_from StandardError, with: :handle_standard_error

  private

  def handle_standard_error(exception)
    render json: { error: exception.message }, status: :unprocessable_entity
  end

  def parameter_missing(exception)
    render json: { error: exception.message }, status: :bad_request
  end

  def authenticate_user_by_token
    token = bearer_token
    return render_unauthorized("Auth token is required") if token.blank?

    auth_token = AuthToken.find_by(token: token)
    return render_unauthorized("Invalid or expired token") if auth_token.blank? || token_expired?(auth_token)

    @current_user = auth_token.user
  end

  def bearer_token
    auth_header = request.headers["Authorization"]
    return nil unless auth_header.present? && auth_header.start_with?("Bearer ")

    auth_header.split(" ").last
  end

  def token_expired?(auth_token)
    auth_token.expires_at < Time.current
  end

  def render_unauthorized(message)
    render json: { error: message }, status: :unauthorized and return
  end

  def current_user
    @current_user
  end
end
