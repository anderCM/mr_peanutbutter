# spec/controllers/wallets_controller_spec.rb
require 'rails_helper'

RSpec.describe WalletsController, type: :controller do
  let(:user) { create(:user) }
  let(:auth_token) { create(:auth_token, user: user) }
  let!(:wallet1) { create(:wallet, user: user, currency: 'usd', balance: 100) }
  let!(:wallet2) { create(:wallet, user: user, currency: 'btc', balance: 50) }

  describe "GET #index" do
    context "when valid token is provided" do
      before do
        request.headers['Authorization'] = "Bearer #{auth_token.token}"
        get :index, params: { user_id: user.id }
      end

      it "return a success http status" do
        expect(response).to have_http_status(:success)
      end

      it "return user wallets" do
        wallets = JSON.parse(response.body)
        expect(wallets.count).to eq(2)
        expect(wallets.map { |w| w['id'] }).to include(wallet1.id, wallet2.id)
      end
    end

    context "when token is not provided" do
      before { get :index, params: { user_id: user.id } }

      it "return an unauthorized http status" do
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns an error message" do
        error = JSON.parse(response.body)['error']
        expect(error).to eq("Auth token is required")
      end
    end

    context "when token is provided but is invalid" do
      before do
        request.headers['Authorization'] = "Bearer abcdef"
        get :index, params: { user_id: user.id }
      end

      it "return an unauthorized http status" do
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns an error message" do
        error = JSON.parse(response.body)['error']
        expect(error).to eq("Invalid or expired token")
      end
    end

    context "when token is provided but it is expired" do
      before do
        auth_token.update!(expires_at: 1.hour.ago)
        request.headers['Authorization'] = "Bearer #{auth_token.token}"
        get :index, params: { user_id: user.id }
      end

      it "return an unauthorized http status" do
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns an error message" do
        error = JSON.parse(response.body)['error']
        expect(error).to eq("Invalid or expired token")
      end
    end
  end
end
