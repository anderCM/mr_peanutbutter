class CreatedUserSerializer < ActiveModel::Serializer
  attributes :first_name, :last_name, :email

  # Relation with AuthTokenSerializer
  has_one :auth_token, serializer: AuthTokenSerializer

  # Accessor to get the current auth token
  def auth_token
    object.current_auth_token
  end
end
