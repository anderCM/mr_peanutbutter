require "rails_helper"

RSpec.describe UserAuthorization, type: :controller do
  controller(ApplicationController) do
    include UserAuthorization

    def index
      authorize_user
      return if performed?

      render json: { message: "Success" }
    end

    def render_unauthorized(message)
      render json: { error: message }, status: :unauthorized
    end
  end

  let(:user)       { create(:user) }
  let(:admin)      { create(:user, admin: true) }
  let(:other_user) { create(:user) }
  let(:auth_token) { create(:auth_token, user: user) }

  before do
    routes.draw { get "index" => "anonymous#index" }
    request.headers['Authorization'] = "Bearer #{auth_token.token}"
  end

  context "when current_user is admin" do
    before do
      allow(controller).to receive(:current_user).and_return(admin)
      get :index, params: { user_id: other_user.id }
    end

    it "allows access and renders success" do
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["message"]).to eq("Success")
    end
  end

  context "when current_user id matches requested user_id" do
    before do
      allow(controller).to receive(:current_user).and_return(user)
      get :index, params: { user_id: user.id }
    end

    it "allows access and renders success" do
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["message"]).to eq("Success")
    end
  end

  context "when current_user is not admin and id does not match" do
    before do
      allow(controller).to receive(:current_user).and_return(user)
      get :index, params: { user_id: other_user.id }
    end

    it "renders unauthorized error" do
      expect(response).to have_http_status(:unauthorized)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("You are not authorized to access this resource")
    end
  end
end
