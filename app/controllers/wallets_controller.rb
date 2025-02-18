class WalletsController < ApplicationController
  before_action :authorize_user

  def index
    user = User.find(params[:user_id])
    wallets = user.wallets
    render json: wallets, each_serializer: WalletSerializer
  end
end
