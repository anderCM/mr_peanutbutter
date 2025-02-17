require 'rails_helper'

RSpec.describe WelcomeUserService, type: :service do
  let(:user) { create(:user) }

  describe '#process' do
    context 'when wallets are created successfully' do
      it 'returns a success response' do
        service = WelcomeUserService.new(user)

        expect(service.process).to include(success: true, user: user)
      end
    end

    context 'when wallet creation fails' do
      it 'returns an error response' do
        allow_any_instance_of(WalletService).to receive(:create_wallet).and_raise(ActiveRecord::RecordInvalid.new(Wallet.new))

        service = WelcomeUserService.new(user)
        result = service.process

        expect(result[:success]).to be_falsey
        expect(result[:error]).to eq('Invalid data provided')
      end
    end

    context 'when an unexpected error occurs' do
      it 'returns an error response' do
        allow_any_instance_of(WelcomeUserService).to receive(:create_welcome_wallets).and_raise(StandardError.new('Unexpected error'))

        service = WelcomeUserService.new(user)
        result = service.process

        expect(result[:success]).to be_falsey
        expect(result[:error]).to eq('Could not complete registration')
      end
    end
  end

  describe '#create_wallet_with_balance' do
    let(:service) { WelcomeUserService.new(user) }

    context 'when amount is positive' do
      it 'creates a wallet and adds balance' do
        wallet_service = instance_double(WalletService)
        allow(WalletService).to receive(:new).and_return(wallet_service)
        allow(wallet_service).to receive(:create_wallet).and_return(double(balance: 0))
        allow(wallet_service).to receive(:add_balance).with(10.0)

        expect { service.send(:create_wallet_with_balance, 'usd', 10.0) }.not_to raise_error
      end
    end
  end
end
