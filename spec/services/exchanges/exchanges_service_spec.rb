require "rails_helper"

RSpec.describe Exchanges::ExchangesService, type: :service do
  let(:user)               { create(:user) }
  let(:amount)             { 1000.0 }
  let(:sending_currency)   { "usd" }
  let(:receiving_currency) { "bitcoin" }

  describe "#process" do
    context "when ExchangesCalculatorService returns an error" do
      let(:error_result) do
        ServiceResult.new(
          success: false,
          error_message: "Price service error",
          error_code: 500,
          http_status: 500
        )
      end

      before do
        allow_any_instance_of(Exchanges::ExchangesService)
          .to receive(:calculate_crypto_price)
          .and_return(error_result)
      end

      it "returns error truncating the process" do
        service = described_class.new(
          user: user,
          amount: amount,
          sending_currency: sending_currency,
          receiving_currency: receiving_currency
        )
        result = service.process

        expect(result.success?).to be false
        expect(result.error_message).to eq("Price service error")
        expect(result.error_code).to eq(500)
      end
    end

    context "when ExchangesCalculatorService is successful" do
      let(:crypto_data) { { total_price: 0.01, exchange_rate: 96000 } }
      let(:transaction_exchange) { double("Exchange", status: "finished") }
      let(:transaction_result) do
        ServiceResult.new(success: true, data: transaction_exchange, http_status: 200)
      end

      before do
        allow_any_instance_of(Exchanges::ExchangesService)
          .to receive(:calculate_crypto_price)
          .and_return(crypto_data)

        exchange_transaction_service_double = double("ExchangesTransactionService", process: transaction_result)
        allow_any_instance_of(Exchanges::ExchangesService)
          .to receive(:exchange_transaction_service)
          .and_return(exchange_transaction_service_double)
      end

      it "assign final_price, exchange_rate y and call ExchangeTransactionService" do
        service = described_class.new(
          user: user,
          amount: amount,
          sending_currency: sending_currency,
          receiving_currency: receiving_currency
        )
        result = service.process

        expect(service.instance_variable_get(:@final_price)).to eq(crypto_data[:total_price])
        expect(service.instance_variable_get(:@exchange_rate)).to eq(crypto_data[:exchange_rate])
        expect(result.success?).to be true
        expect(result.data).to eq(transaction_exchange)
      end
    end
  end
end
