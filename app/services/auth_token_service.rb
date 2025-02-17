class AuthTokenService
  def initialize(user)
    @user = user
  end

  def generate_tokens
    raise "User does not exist" unless valid_user?

    @user.auth_tokens.create(
      token: SecureRandom.hex,
      refresh_token: SecureRandom.hex,
      expires_at: 1.day.from_now,
      refresh_token_expires_at: 1.week.from_now
    )
  end

  private

  def valid_user?
    @user.present?
  end
end
