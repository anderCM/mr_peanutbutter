module Exchanges
  class ExchangeTransactionService
    def initialize(user:, amount_sent:, exchange_type:, currency_sent:, amount_received:, currency_received:, exchange_rate:)
      @user = user
      @amount_sent = amount_sent
      @exchange_type = exchange_type
      @currency_sent = currency_sent
      @amount_received = amount_received
      @currency_received = currency_received
      @exchange_rate = exchange_rate
    end

    def process
      balance_validation = validate_enough_balance

      unless balance_validation.success?
        new_exchange.update(comments: 'Not enough funds', status: 'canceled')
        return balance_validation
      end

      ActiveRecord::Base.transaction do
        process_wallets!
        new_exchange.update!(status: 'finished')
      end

      ServiceResult.new(success: true, data: new_exchange, http_status: 200)
    rescue StandardError => e
      ServiceResult.new(success: false, error_message: e.message, error_code: 500, http_status: 500)
    end

    private

    attr_reader :user, :amount_sent, :exchange_type , :currency_sent, :amount_received, :currency_received, :exchange_rate

    def new_exchange
      @new_exchange ||= user.exchanges.create(
        exchange_type:,
        amount_sent:,
        currency_sent:,
        amount_received:,
        currency_received:,
        exchange_rate:
      )
    end

    def affected_wallets
      @affected_wallets ||= user.wallets.where(currency: [currency_sent, currency_received])
    end

    def validate_enough_balance
      unless sending_wallet
        return ServiceResult.new(
          success: false,
          error_message: "Wallet for #{currency_sent} currency was not found",
          error_code: 404,
          http_status: 404
        )
      end

      difference = sending_wallet.balance - amount_sent
      unless difference.positive?
        return ServiceResult.new(
          success: false,
          error_message: "Not enough funds in wallet. Current balance: #{sending_wallet.balance}",
          error_code: 422,
          http_status: 422
        )
      end

      ServiceResult.new(success: true)
    end

    def create_transaction(wallet, operation_type, amount, previous_balance, new_balance)
     wallet.wallet_exchanges.create(
        exchange: new_exchange,
        operation_type:,
        amount:,
        previous_balance:,
        new_balance:
     )
    end

    def process_wallets!
      # Subtract funds from sending wallet
      previous_sending_balance = sending_wallet.balance
      new_sending_balance = previous_sending_balance - amount_sent
      sending_wallet.update!(balance: new_sending_balance)
      create_transaction(sending_wallet, 'debit', amount_sent, previous_sending_balance, new_sending_balance)

      # Add funds to receiving wallet
      previous_receiving_balance = receiving_wallet.balance
      new_receiving_balance = receiving_wallet.balance + amount_received
      receiving_wallet.update!(balance: new_receiving_balance)
      create_transaction(receiving_wallet, 'credit', amount_received, previous_receiving_balance, new_receiving_balance)
    end

    def receiving_wallet
      @receiving_wallet ||= affected_wallets.find_by_currency currency_received
    end

    def sending_wallet
      @sending_wallet ||= affected_wallets.find_by_currency currency_sent
    end
  end
end
