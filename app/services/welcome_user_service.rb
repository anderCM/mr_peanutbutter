class WelcomeUserService
  # For functional porpuses, we are creating wallets with welcome amounts

  # Welcome amounts for currencies
  WELCOME_AMOUNTS = {
    'usd' => 150000.0,
    'bitcoin' => 8.5
  }.freeze

  def initialize(user)
    @user = user
  end

  def process
    # Begin transaction to ensure data consistency
    # We can add more steps here if needed
    ApplicationRecord.transaction do
      create_welcome_wallets
    end

    { success: true, user: @user }
  rescue ActiveRecord::RecordInvalid => e
    log_error('Wallet creation failed', e)
    { success: false, error: 'Invalid data provided', details: e.message }
  rescue StandardError => e
    log_error('Unexpected error during user onboarding', e)
    { success: false, error: 'Could not complete registration' }
  end

  private

  def create_welcome_wallets
    WELCOME_AMOUNTS.each do |currency, initial_amount|
      create_wallet_with_balance(currency, initial_amount)
    end
  end

  def create_wallet_with_balance(currency, amount)
    wallet_service = WalletService.new(
      user_id: @user.id,
      currency: currency
    )

    # wallet_service will validate and spread errors
    wallet = wallet_service.create_wallet
    wallet_service.add_balance(amount)
  rescue ArgumentError => e
    log_error("Invalid amount for welcome balance", e)
    raise ActiveRecord::RecordInvalid.new(
      "Could not set welcome balance: #{e.message}"
    )
  rescue StandardError => e
    log_error("Failed to create wallet for #{currency}", e)
    raise
  end

  def log_error(message, error)
    Rails.logger.error(
      "WelcomeUser Error - #{message}: #{error.message}\n#{error.backtrace.join("\n")}"
    )
  end
end
