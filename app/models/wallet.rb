class Wallet < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :wallet_exchanges, dependent: :destroy

  # Validations
  validates :currency, presence: true

  # This can be changed or removed according to requirements
  enum currency: {
    usd: 'usd',
    bitcoin: 'bitcoin'
  }
end