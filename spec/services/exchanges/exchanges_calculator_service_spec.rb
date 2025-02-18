require "rails_helper"

RSpec.describe Exchanges::ExchangesCalculatorService, type: :service do
  let(:amount)           { 1000.0 }
  let(:crypto_currency)  { "bitcoin" }
  let(:base_currency)    { "usd" }
  let(:exchange_type)    { service_exchange_type }
  subject do
    described_class.new(
      amount: amount,
      crypto_currency: crypto_currency,
      base_currency: base_currency,
      exchange_type: exchange_type
    )
  end

  context "when CryptoPriceService returns a successful response" do
    let(:crypto_price) { 95_988.54 }
    let(:service_result_success) do
      ServiceResult.new(
        success: true,
        data: { crypto_currency => { base_currency => crypto_price } },
        http_status: 200
      )
    end

    before do
      allow(CryptoPriceService).to receive(:call)
        .with(coin_ids: [crypto_currency])
        .and_return(service_result_success)
    end

    context "and operation type is 'buy'" do
      let(:service_exchange_type) { "buy" }

      it "calculate total_price as a division" do
        result = subject.calculate
        expected_total = amount.to_f / crypto_price

        expect(result.success?).to be true
        expect(result.data[:total_price]).to be_within(0.0001).of(expected_total)
        expect(result.data[:exchange_rate]).to eq(crypto_price)
      end
    end

    context "and operation type is 'sell'" do
      let(:service_exchange_type) { "sell" }

      it "calculate total_prices as a multiplication" do
        result = subject.calculate
        expected_total = amount.to_f * crypto_price

        expect(result.success?).to be true
        expect(result.data[:total_price]).to be_within(0.0001).of(expected_total)
        expect(result.data[:exchange_rate]).to eq(crypto_price)
      end
    end
  end

  context "when CryptoPriceService returns an error" do
    let(:error_response) do
      ServiceResult.new(
        success: false,
        error_message: "Error fetching price",
        error_code: 500,
        http_status: 500
      )
    end

    let(:service_exchange_type) { "buy" }

    before do
      allow(CryptoPriceService).to receive(:call)
        .with(coin_ids: [crypto_currency])
        .and_return(error_response)
    end

    it "spread error from CryptoPriceService" do
      result = subject.calculate

      expect(result.success?).to be false
      expect(result.error_message).to eq("Error fetching price")
      expect(result.error_code).to eq(500)
    end
  end

  context "when fetched price is not number" do
    let(:non_numeric_response) do
      ServiceResult.new(
        success: true,
        data: { crypto_currency => { base_currency => "NaN" } },
        http_status: 200
      )
    end

    let(:service_exchange_type) { "buy" }

    before do
      allow(CryptoPriceService).to receive(:call)
        .with(coin_ids: [crypto_currency])
        .and_return(non_numeric_response)
    end

    it "returns error indicating that fetching failed" do
      result = subject.calculate

      expect(result.success?).to be false
      expect(result.error_message).to eq("Crypto price fetch failed")
    end
  end
end
