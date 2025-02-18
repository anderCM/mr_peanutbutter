require 'rails_helper'

RSpec.describe WalletExchange, type: :model do
  describe 'associations' do
    it { should belong_to(:wallet) }
    it { should belong_to(:exchange) }
  end
 
  describe 'validations' do
    it { should validate_presence_of(:amount) }
    it { should validate_presence_of(:previous_balance) }
    it { should validate_presence_of(:new_balance) }
 
    it 'has valid operation_type enum values' do
      expect(WalletExchange.operation_types.keys).to match_array(%w[credit debit])
    end
  end
end
