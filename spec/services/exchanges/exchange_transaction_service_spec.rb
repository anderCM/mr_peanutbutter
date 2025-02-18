require "rails_helper"

RSpec.describe Exchanges::ExchangeTransactionService, type: :service do
  let(:user) { create(:user) }
  let!(:usd_wallet)   { create(:wallet, user: user, currency: "usd", balance: 150000.0) }
  let!(:btc_wallet)   { create(:wallet, user: user, currency: "bitcoin", balance: 8.5) }


  let(:amount_sent)      { 1000.0 }
  let(:exchange_rate)    { 95988.54 }
  let(:exchange_type)    { "buy" }
  let(:amount_received)  { amount_sent / exchange_rate }

  subject do
    described_class.new(
      user:               user,
      amount_sent:        amount_sent,
      exchange_type:      exchange_type,
      currency_sent:      "usd",
      amount_received:    amount_received,
      currency_received:  "bitcoin",
      exchange_rate:      exchange_rate
    )
  end

  describe "#process" do
    context "when sending wallet does not exist" do
      before do
        usd_wallet.destroy
      end

      it "retorns an error with code 404" do
        result = subject.process
        expect(result.success?).to be false
        expect(result.error_message).to eq("Wallet for usd currency was not found")
        expect(result.error_code).to eq(404)
      end
    end

    context "when sending wallet does not enough funds" do
      before do
        usd_wallet.update!(balance: 500.0)
      end

      it "returns an error with code 422" do
        result = subject.process
        expect(result.success?).to be false
        expect(result.error_message).to include("Not enough funds in wallet. Current balance:")
        expect(result.error_code).to eq(422)
      end
    end

    context "when transaction is success" do
      it "update wallets balance and create wallet_exchanges" do
        initial_usd_balance = usd_wallet.balance
        initial_btc_balance = btc_wallet.balance

        result = subject.process

        expect(result.success?).to be true
        exchange = result.data
        expect(exchange.status).to eq("finished")

        usd_wallet.reload
        btc_wallet.reload

        expect(usd_wallet.balance).to eq(initial_usd_balance - amount_sent)
        expect(btc_wallet.balance.round(2)).to eq((initial_btc_balance + amount_received).round(2))

        expect(usd_wallet.wallet_exchanges.count).to eq(1)
        expect(btc_wallet.wallet_exchanges.count).to eq(1)

        debit_exchange = usd_wallet.wallet_exchanges.first
        credit_exchange = btc_wallet.wallet_exchanges.first

        expect(debit_exchange.operation_type).to eq("debit")
        expect(debit_exchange.amount).to eq(amount_sent)
        expect(debit_exchange.previous_balance).to eq(initial_usd_balance)
        expect(debit_exchange.new_balance).to eq(initial_usd_balance - amount_sent)

        expect(credit_exchange.operation_type).to eq("credit")
        expect(credit_exchange.amount.round(2)).to eq(amount_received.round(2))
        expect(credit_exchange.previous_balance).to eq(initial_btc_balance)
        expect(credit_exchange.new_balance.round(2)).to eq((initial_btc_balance + amount_received).round(2))
      end
    end
  end
end
