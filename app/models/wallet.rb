class Wallet < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :wallet_exchanges

  # Validations
  validates :currency, presence: true

  # This can be changed or removed according to requirements
  enum currency: {
    usd: 'usd',
    btc: 'btc'
  }
end