module Exchanges
  class ExchangesService
    VALID_CURRENCIES = Wallet.currencies.values
    DEFAULT_CRYPTO_CURRENCY = "bitcoin"
    DEFAULT_BASE_CURRENCY = "usd"

    def initialize(user:, amount:, sending_currency:, receiving_currency:)
      @user = user
      @amount = amount
      @sending_currency = sending_currency
      @receiving_currency = receiving_currency

      validate!
    end

    def process
      crypto_prices = calculate_crypto_price
      return crypto_prices unless crypto_prices.is_a?(Hash)

      @final_price = crypto_prices[:total_price]
      @exchange_rate = crypto_prices[:exchange_rate]

      exchange_transaction_service.process
    end

    private

    attr_reader :user, :amount, :sending_currency, :receiving_currency

    def validate!
      raise ArgumentError, "Invalid amount" unless amount.is_a?(Numeric) && amount.positive?
      raise ArgumentError, "Invalid sending currency" unless VALID_CURRENCIES.include?(sending_currency)
      raise ArgumentError, "Invalid receiving currency" unless VALID_CURRENCIES.include?(receiving_currency)
    end

    def calculate_crypto_price
      # We can change this to real crypto and base currencies if needed
      crypto_currency = DEFAULT_CRYPTO_CURRENCY
      base_currency = DEFAULT_BASE_CURRENCY
      
      service = Exchanges::ExchangesCalculatorService.new(amount:, crypto_currency:, base_currency:, exchange_type:)
      result = service.calculate
      return result unless result.success?

      result.data
    end

    # We can change this according to requirements
    def exchange_type
      sending_currency == DEFAULT_BASE_CURRENCY ? 'buy' : 'sell'
    end

    def exchange_transaction_service
      @exchange_transaction_service ||= Exchanges::ExchangeTransactionService.new(
        user:               user,
        amount_sent:        amount,
        exchange_type:      exchange_type,
        currency_sent:      sending_currency,
        amount_received:    @final_price,
        currency_received:  receiving_currency,
        exchange_rate:      @exchange_rate
      )
    end
  end
end
