class AuthTokenSerializer < ActiveModel::Serializer
  attributes :token, :refresh_token, :expires_at, :refresh_token_expires_at
end
