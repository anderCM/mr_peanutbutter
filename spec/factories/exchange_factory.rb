FactoryBot.define do
  factory :exchange do
    user
    exchange_type { "buy" }
    amount_sent { 5000 }
    currency_sent { "usd"}
    amount_received { 0.05 }
    currency_received { "bitcoin" }
    exchange_rate { 95658.05 }
    status { "finished" }
    comments { nil }
  end
end
  