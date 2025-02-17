require 'rails_helper'

RSpec.describe Wallet, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:wallet_exchanges) }
  end

  describe 'validations' do
    it { should validate_presence_of(:currency) }

    it 'has valid currency enum values' do
      expect(Wallet.currencies.keys).to match_array(%w[usd btc])
    end
  end
end
