require 'rails_helper'

RSpec.describe Exchange, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_one(:wallet_exchange) }
  end
 
  describe 'validations' do
    it { should validate_presence_of(:exchange_type) }
    it { should validate_presence_of(:amount_sent) }
    it { should validate_presence_of(:currency_sent) }
    it { should validate_presence_of(:amount_received) }
    it { should validate_presence_of(:currency_received) }
    it { should validate_presence_of(:exchange_rate) }
 
    it 'has valid exchange_type enum values' do
      expect(Exchange.exchange_types.keys).to match_array(%w[buy sell])
    end
 
    it 'has valid status enum values' do
      expect(Exchange.statuses.keys).to match_array(%w[pending finished canceled])
    end
  end
end
