require "rails_helper"

RSpec.describe ExchangesController, type: :controller do
  let(:user) { create(:user) }
  let(:auth_token) { create(:auth_token, user: user) }
  let(:exchange_params) do
    {
      amount: 1000,
      sending_currency: "usd",
      receiving_currency: "bitcoin"
    }
  end
  let(:service_double) { instance_double(Exchanges::ExchangesService) }

  let(:normalize) do
    lambda do |hash|
      hash.transform_keys(&:to_s).tap do |h|
        h["amount_received"] = h["amount_received"].to_f
        h["amount_sent"]     = h["amount_sent"].to_f
        h["exchange_rate"]   = h["exchange_rate"].to_f
      end
    end
  end

  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "POST #create" do
    context "when service is successful" do
      let(:exchange_data) { { id: 1, exchange_type: "buy", status: "finished" } }
      let(:success_result) do
        ServiceResult.new(success: true, data: exchange_data, http_status: 200)
      end

      before do
        expect(Exchanges::ExchangesService).to receive(:new).with(
          user: user,
          amount: exchange_params[:amount],
          sending_currency: exchange_params[:sending_currency],
          receiving_currency: exchange_params[:receiving_currency]
        ).and_return(service_double)

        allow(service_double).to receive(:process).and_return(success_result)
      end

      it "renders json data and OK status" do
        request.headers['Authorization'] = "Bearer #{auth_token.token}"
        post :create, params: { user_id: user.id }.merge(exchange_params), as: :json

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to eq(exchange_data.as_json)
      end
    end

    context "when service returns an error" do
      let(:error_result) do
        ServiceResult.new(success: false, error_message: "Error occurred", error_code: 422, http_status: 422)
      end

      before do
        expect(Exchanges::ExchangesService).to receive(:new).with(
          user: user,
          amount: exchange_params[:amount],
          sending_currency: exchange_params[:sending_currency],
          receiving_currency: exchange_params[:receiving_currency]
        ).and_return(service_double)

        allow(service_double).to receive(:process).and_return(error_result)
      end

      it "renders JSON with error and error status" do
        request.headers['Authorization'] = "Bearer #{auth_token.token}"
        post :create, params: { user_id: user.id }.merge(exchange_params), as: :json

        expect(response).to have_http_status(422)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Error occurred")
        expect(json["code"]).to eq(422)
      end
    end
  end

  describe "GET #index" do
    before do
      create_list(:exchange, 2, user: user)
      request.headers['Authorization'] = "Bearer #{auth_token.token}"
    end

    it "renders a list of exchanges" do
      get :index, params: { user_id: user.id }, as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to be_an(Array)
      expect(json.size).to eq(2)

      expected = ActiveModelSerializers::SerializableResource.new(
        user.exchanges, each_serializer: ExchangeSerializer
      ).as_json.map(&normalize)
      actual = json.map { |ex| normalize.call(ex) }
      expect(actual).to eq(expected)
    end
  end

  describe "GET #show" do
    context "when the exchange exists" do
      let!(:exchange) { create(:exchange, user: user) }
      before do
        request.headers['Authorization'] = "Bearer #{auth_token.token}"
      end

      it "returns the exchange data with status ok" do
        get :show, params: { user_id: user.id, id: exchange.id }, as: :json

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expected = ActiveModelSerializers::SerializableResource.new(
          exchange, serializer: ExchangeSerializer
        ).as_json

        expect(normalize.call(json)).to eq(normalize.call(expected))
      end
    end

    context "when the exchange does not exist" do
      before do
        request.headers['Authorization'] = "Bearer #{auth_token.token}"
      end

      it "returns a 404 error" do
        get :show, params: { user_id: user.id, id: 99999 }, as: :json

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Exchange not found")
      end
    end
  end
end
