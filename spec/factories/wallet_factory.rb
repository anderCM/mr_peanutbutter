FactoryBot.define do
  factory :wallet do
    user
    currency { 'usd' }
    balance { 0 }
  end
end