module Exchanges
  class ExchangesCalculatorService
    def initialize(amount:, crypto_currency:, base_currency:, exchange_type:)
      @amount = amount
      @crypto_currency = crypto_currency
      @base_currency = base_currency
      @exchange_type = exchange_type
    end

    def calculate
      crypto_price = fetch_crypto_price
      return crypto_price unless crypto_price.is_a?(Numeric)

      total_price = if @exchange_type == 'buy'
        @amount.to_f / crypto_price
      else
        @amount.to_f * crypto_price
      end

      data = { total_price: total_price, exchange_rate: crypto_price }

      ServiceResult.new(success: true, data:, http_status: 200)
    rescue StandardError => e
      ServiceResult.new(success: false, error_message: e.message, error_code: 500, http_status: 500)
    end

    private

    attr_reader :crypto_currency, :base_currency

    def fetch_crypto_price
      response = CryptoPriceService.call(coin_ids: [crypto_currency])
      return response unless response.success?

      print response
  
      price = response.data[crypto_currency][base_currency]
      price.is_a?(Numeric) ? price : ServiceResult.new(
        success: false,
        error_message: "Crypto price fetch failed",
        error_code: 500,
        http_status: 500
      )
    end
  end
end
