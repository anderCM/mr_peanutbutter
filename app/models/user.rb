class User < ApplicationRecord
  # Default device modules
  devise :database_authenticatable, :registerable, :validatable

  # Associations
  has_many :auth_tokens, dependent: :destroy
  has_many :wallets, dependent: :destroy
  has_many :exchanges, dependent: :destroy

  # Virtual accessor to store the current auth token when create a new one
  attr_accessor :current_auth_token

  # Validations
  validates :first_name, :last_name, :email, presence: true
  validates :admin, inclusion: { in: [true, false] }

  def admin?
    admin
  end
end
