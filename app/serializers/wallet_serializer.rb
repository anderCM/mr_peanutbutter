class WalletSerializer < ActiveModel::Serializer
  attributes :id, :currency, :balance
end