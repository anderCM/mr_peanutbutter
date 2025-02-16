class PricesController < ActionController::Base
  # Coin ids can be changed to be received by params according to requirements. Now is static because it is the only one required
  DEFAULT_COIN_ID = "bitcoin"

  def index
    result = CryptoPriceService.call(coin_ids: [ DEFAULT_COIN_ID ])

    if result.success?
      render json: result.data, status: :ok
    else
      render json: {
        error:  result.error_message,
        code:   result.error_code
      }, status: result.http_status
    end
  end
end
