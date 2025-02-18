require 'swagger_helper'

RSpec.describe 'Prices API', type: :request, swagger_doc: 'v1/swagger.yaml' do
  path '/prices' do
    get 'Get crypto prices (only BTC for the moment)' do
      tags 'Prices'
      produces 'application/json'
      security []

      response '200', 'Prices returned' do
        schema type: :object,
          properties: {
            bitcoin: {
              type: :object,
              properties: {
                usd: { type: :number }
              }
            }
          },
          required: [ 'bitcoin' ]

        run_test!
      end

      response '503', 'Service Unavailable' do
        schema type: :object,
          properties: {
            error: { type: :string },
            code: { type: :integer }
          },
          required: [ 'error', 'code' ]

        run_test!
      end

      response '500', 'Internal Server Error' do
        schema type: :object,
          properties: {
            error: { type: :string },
            code: { type: :integer }
          },
          required: [ 'error', 'code' ]

        run_test!
      end
    end
  end
end
