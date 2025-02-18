class WalletsController < ApplicationController
  def index
    wallets = current_user.wallets
    render json: wallets, each_serializer: WalletSerializer
  end
end
