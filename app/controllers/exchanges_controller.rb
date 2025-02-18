class ExchangesController < ApplicationController
  before_action :authorize_user

  def create
    user = User.find(params[:user_id])
    service = Exchanges::ExchangesService.new(
      user: user,
      amount: exchange_params[:amount],
      sending_currency: exchange_params[:sending_currency],
      receiving_currency: exchange_params[:receiving_currency]
    )
    result = service.process

    if result.success?
      render json: result.data, status: :ok
    else
      render json: {
        error:  result.error_message,
        code:   result.error_code
      }, status: result.http_status
    end
  end

  def index
    user = User.find(params[:user_id])
    exchanges = user.exchanges
    render json: exchanges, each_serializer: ExchangeSerializer
  end

  def show
    user = User.find(params[:user_id])
    exchange = user.exchanges.find(params[:id])
    render json: exchange, serializer: ExchangeSerializer, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Exchange not found" }, status: :not_found
  end

  private

  def exchange_params
    params.permit(:amount, :sending_currency, :receiving_currency)
  end
end