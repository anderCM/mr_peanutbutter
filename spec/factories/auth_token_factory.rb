FactoryBot.define do
  factory :auth_token do
    user
    token { SecureRandom.hex }
    expires_at { 1.day.from_now }
    refresh_token { SecureRandom.hex }
    refresh_token_expires_at { 1.week.from_now }
  end
end
