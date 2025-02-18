class Exchange < ApplicationRecord
  # Associations
  belongs_to :user
  has_one :wallet_exchange, dependent: :destroy

  # Validations
  validates :exchange_type, :amount_sent, :currency_sent, :amount_received, :currency_received, :exchange_rate, presence: true

  enum exchange_type: {
    buy: 'buy',
    sell: 'sell'
  }

  enum status: {
    pending: 'pending',
    finished: 'finished',
    canceled: 'canceled'
  }
end