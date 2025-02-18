class WalletExchangeSerializer < ActiveModel::Serializer
  attributes :id, :exchange_id, :wallet_id, :operation_type, :amount, :previous_balance, :new_balance
end
