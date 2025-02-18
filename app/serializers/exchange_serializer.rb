class ExchangeSerializer < ActiveModel::Serializer
  attributes :id, :exchange_type, :amount_sent, :currency_sent,
             :amount_received, :currency_received, :exchange_rate, :status,
             :comments

  has_many :wallet_exchanges, key: :details, serializer: WalletExchangeSerializer
end