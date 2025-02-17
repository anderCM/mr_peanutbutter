require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  describe "POST #create" do
    let(:default_password) { "12345678" }
    let!(:user) { create(:user, password: default_password, password_confirmation: default_password) }

    let(:valid_params) { { email: user.email, password: default_password } }
    let(:invalid_params) { { email: user.email, password: "WrongPassword" } }

    let(:fake_token) do
      user.auth_tokens.create!(
        token: "fake_token_123",
        refresh_token: "fake_refresh_123",
        expires_at: 1.day.from_now,
        refresh_token_expires_at: 1.week.from_now
      )
    end

    before do
      allow_any_instance_of(AuthTokenService).to receive(:generate_tokens).and_return(fake_token)
    end

    context "with valid credentials" do
      it "returns status ok and the created user with token" do
        post :create, params: valid_params, as: :json

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["first_name"]).to eq(user.first_name)
        expect(json["last_name"]).to eq(user.last_name)
        expect(json["email"]).to eq(user.email)
        expect(json["auth_token"]).to be_present
        expect(json["auth_token"]["token"]).to eq("fake_token_123")
      end
    end

    context "with invalid credentials" do
      it "returns unauthorized status and error message" do
        post :create, params: invalid_params, as: :json

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Invalid email or password")
      end
    end
  end
end
