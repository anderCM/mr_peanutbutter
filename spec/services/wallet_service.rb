require 'rails_helper'

RSpec.describe WalletService, type: :service do
  let(:user) { create(:user) }
  let(:currency) { 'usd' }
  let(:initial_balance) { 100.0 }
  let!(:wallet) { create(:wallet, user_id: user.id, currency: currency, balance: initial_balance) }

  describe '#initialize' do
    context 'with valid currency' do
      it 'initializes successfully' do
        expect { WalletService.new(user_id: user.id, currency: currency) }.not_to raise_error
      end
    end

    context 'with invalid currency' do
      it 'raises an InvalidCurrencyError' do
        expect { WalletService.new(user_id: user.id, currency: 'eur') }.to raise_error(InvalidCurrencyError)
      end
    end
  end

  describe '#create_wallet' do
    context 'when wallet already exists' do
      it 'returns the existing wallet' do
        service = WalletService.new(user_id: user.id, currency: currency)
        expect(service.create_wallet).to eq(wallet)
      end
    end

    context 'when wallet does not exist' do
      it 'creates a new wallet' do
        new_currency = 'btc'
        service = WalletService.new(user_id: user.id, currency: new_currency)

        expect { service.create_wallet }.to change { Wallet.count }.by(1)
        expect(Wallet.last.currency).to eq(new_currency)
      end
    end
  end

  describe '#add_balance' do
    let(:service) { WalletService.new(user_id: user.id, currency: currency) }

    context 'with a positive amount' do
      it 'increases the wallet balance' do
        amount = 50.0
        expect { service.add_balance(amount) }.to change { wallet.reload.balance }.by(amount)
      end
    end

    context 'with a negative amount' do
      it 'raises an ArgumentError' do
        expect { service.add_balance(-10) }.to raise_error(ArgumentError, 'Amount must be positive')
      end
    end
  end

  describe '#deduct_balance' do
    let(:service) { WalletService.new(user_id: user.id, currency: currency) }

    context 'with a positive amount and sufficient funds' do
      it 'decreases the wallet balance' do
        amount = 50.0
        expect { service.deduct_balance(amount) }.to change { wallet.reload.balance }.by(-amount)
      end
    end

    context 'with a positive amount and insufficient funds' do
      it 'raises an InsufficientFundsError' do
        amount = initial_balance + 10
        expect { service.deduct_balance(amount) }.to raise_error(InsufficientFundsError)
      end
    end

    context 'with a negative amount' do
      it 'raises an ArgumentError' do
        expect { service.deduct_balance(-10) }.to raise_error(ArgumentError, 'Amount must be positive')
      end
    end
  end
end
