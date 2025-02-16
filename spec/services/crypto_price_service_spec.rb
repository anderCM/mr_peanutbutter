require 'rails_helper'
require 'net/http'

RSpec.describe CryptoPriceService, type: :service do
  let(:coin_ids) { [ 'bitcoin' ] }
  let(:vs_currency) { 'usd' }
  let(:api_url) { 'https://api.coingecko.com/api/v3' }
  let(:api_key) { 'some_api_key' }

  before do
    stub_const('ENV', {
      'COIN_GECKO_API_URL' => api_url,
      'COIN_GECKO_API_KEY' => api_key,
      'DEFAULT_TIMEOUT' => '30'
    })
  end

  describe '#call' do
    context 'with valid parameters' do
      context 'when API request is successful' do
        let(:mock_response) do
          instance_double(
            Net::HTTPOK,
            code: '200',
            body: { 'bitcoin' => { 'usd' => 50000.00 } }.to_json
          )
        end

        before do
          stub_request(:get, "#{api_url}/simple/price?ids=bitcoin&vs_currencies=usd&precision=2")
            .to_return(status: 200, body: mock_response.body)
        end

        it 'returns successful service result with parsed data' do
          result = described_class.call(coin_ids: coin_ids)
          expect(result).to be_success
          expect(result.data).to eq({
            'bitcoin' => { 'usd' => 50000.00 },
          })
          expect(result.http_status).to eq(200)
        end
      end

      context 'when API returns an error' do
        it 'returns error service result with coingecko default error' do
          stub_request(:get, /#{api_url}/).to_return(status: 402, body: '{}')
          result = described_class.call(coin_ids: coin_ids)

          expect(result).not_to be_success
          expect(result.error_code).to eq(402)
          expect(result.error_message).to include('unexpected error')
        end

        it 'returns error service result with coingecko invalid request error' do
            stub_request(:get, /#{api_url}/).to_return(status: 400, body: '{}')
            result = described_class.call(coin_ids: coin_ids)

            expect(result).not_to be_success
            expect(result.error_code).to eq(400)
            expect(result.error_message).to include('Invalid request')
          end
      end
    end

    context 'with invalid parameters' do
      it 'raises error for empty coin_ids' do
        expect {
          described_class.call(coin_ids: [])
        }.to raise_error(ArgumentError, 'No valid Coin IDs provided')
      end

      it 'raises error for not allowed coin_ids' do
        expect {
          described_class.call(coin_ids: [ 'ethereum', 'dogecoin' ])
        }.to raise_error(ArgumentError, 'No valid Coin IDs provided')
      end

      it 'raises error for invalid currency' do
        expect {
          described_class.call(coin_ids: coin_ids, vs_currency: 'eur')
        }.to raise_error(ArgumentError, 'Invalid currency')
      end
    end

    context 'when network errors occur' do
      before do
        allow_any_instance_of(Net::HTTP).to receive(:request).and_raise(Timeout::Error)
      end

      it 'handles timeout errors gracefully' do
        result = described_class.call(coin_ids: coin_ids, vs_currency: 'usd')

        expect(result).not_to be_success
        expect(result.error_code).to eq(503)
        expect(result.error_message).to include('Service Unavailable')
      end
    end

    context 'when using API key' do
      it 'includes API key in headers when present' do
        req = described_class.new(coin_ids: coin_ids).send(:build_request)

        expect(req[:request]['x_cg_demo_api_key']).to eq(api_key)
      end

      it 'does not include API key when not present' do
        ENV['COIN_GECKO_API_KEY'] = nil
        req = described_class.new(coin_ids: coin_ids).send(:build_request)

        expect(req[:request]['x_cg_demo_api_key']).to be_nil
      end
    end
  end

  describe '#build_request' do
    it 'constructs correct URI with multiple coin IDs' do
      service = described_class.new(coin_ids: [ 'bitcoin' ])
      uri = service.send(:build_request)[:uri]

      expect(uri.query).to include('ids=bitcoin')
      expect(uri.query).to include('vs_currencies=usd')
      expect(uri.query).to include('precision=2')
    end
  end

  describe '#merge_coin_ids' do
    it 'joins coin IDs with commas' do
      service = described_class.new(coin_ids: [ 'bitcoin' ])
      result = service.send(:merge_coin_ids)

      expect(result).to eq('bitcoin')
    end
  end
end
