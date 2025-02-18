class WalletExchange < ApplicationRecord
  # Associations
  belongs_to :wallet
  belongs_to :exchange

  # Validations
  validates :amount, :previous_balance, :new_balance, presence: true

  enum operation_type: {
    credit: 'credit',
    debit: 'debit'
  }
end