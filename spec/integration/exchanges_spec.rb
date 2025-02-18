require 'swagger_helper'

RSpec.describe 'Exchanges API', type: :request, swagger_doc: 'v1/swagger.yaml' do
  path '/users/{user_id}/exchange' do
    post 'Creates an exchange transaction' do
      tags 'Exchanges'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          amount: { type: :number, example: 1000 },
          sending_currency: { type: :string, example: 'usd' },
          receiving_currency: { type: :string, example: 'bitcoin' }
        },
        required: ['amount', 'sending_currency', 'receiving_currency']
      }

      response '200', 'Exchange transaction created' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            exchange_type: { type: :string },
            status: { type: :string }
          },
          required: ['id', 'exchange_type', 'status']

        run_test!
      end

      response '422', 'Unprocessable Entity' do
        schema type: :object,
          properties: {
            error: { type: :string },
            code: { type: :integer }
          },
          required: ['error', 'code']

        run_test!
      end

      response '500', 'Internal Server Error' do
        schema type: :object,
          properties: {
            error: { type: :string },
            code: { type: :integer }
          },
          required: ['error', 'code']

        run_test!
      end
    end
  end
end
