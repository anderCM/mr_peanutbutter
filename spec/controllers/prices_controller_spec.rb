require 'rails_helper'

RSpec.describe PricesController, type: :controller do
  let(:coin_ids) { [ 'bitcoin' ] }
  let(:default_price) { 50000.00 }
  describe 'GET #index' do
    context 'when the service returns a successful response' do
      let(:service_response) do
        instance_double('ServiceResult', success?: true, data: { 'bitcoin' => { 'usd' => default_price } }, http_status: 200)
      end

      before do
        allow(CryptoPriceService).to receive(:call).with(coin_ids: coin_ids).and_return(service_response)
        get :index
      end

      it 'returns status 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'renders the correct JSON response' do
        json_response = JSON.parse(response.body)
        expect(json_response).to eq({ 'bitcoin' => { 'usd' => default_price } })
      end
    end

    context 'when the service returns an error' do
      let(:service_response) do
        instance_double('ServiceResult', success?: false, error_message: 'Service Unavailable', error_code: 503, http_status: 503)
      end

      before do
        allow(CryptoPriceService).to receive(:call).with(coin_ids: coin_ids).and_return(service_response)
        get :index
      end

      it 'returns status 503' do
        expect(response).to have_http_status(:service_unavailable)
      end

      it 'renders the correct error message' do
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Service Unavailable')
        expect(json_response['code']).to eq(503)
      end
    end

    context 'when the service returns an invalid JSON error' do
      let(:service_response) do
        instance_double('ServiceResult', success?: false, error_message: 'Invalid JSON response', error_code: 500, http_status: 500)
      end

      before do
        allow(CryptoPriceService).to receive(:call).with(coin_ids: coin_ids).and_return(service_response)
        get :index
      end

      it 'returns status 500' do
        expect(response).to have_http_status(:internal_server_error)
      end

      it 'renders the correct error message' do
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid JSON response')
        expect(json_response['code']).to eq(500)
      end
    end
  end
end
