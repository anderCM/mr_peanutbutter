class WalletService
  def initialize(user_id:, currency:)
    @user_id = user_id
    @currency = currency

    validate_currency!
  end

  def create_wallet
    return current_wallet if current_wallet.present?

    Wallet.create!(user_id: @user_id, currency: @currency)
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("Failed to create wallet: #{e.message}")
    raise
  end

  def add_balance(amount)
    raise ArgumentError, "Amount must be positive" unless valid_amount?(amount)

    current_wallet.with_lock do
      current_wallet.update!(balance: current_wallet.balance + amount)
    end
  end

  def deduct_balance(amount)
    raise ArgumentError, "Amount must be positive" unless valid_amount?(amount)

    current_wallet.with_lock do
      if current_wallet.balance < amount
        raise InsufficientFundsError, "Insufficient funds for deduction"
      end

      current_wallet.update!(balance: current_wallet.balance - amount)
    end
  end

  private

  def current_wallet
    @current_wallet ||= Wallet.find_by(user_id: @user_id, currency: @currency)
  end

  def valid_amount?(amount)
    amount.positive?
  end

  def valid_currency?
    @currency.in?(Wallet.currencies.keys)
  end

  def validate_currency!
    raise InvalidCurrencyError, "Invalid currency: #{@currency}" unless valid_currency?
  end
end
