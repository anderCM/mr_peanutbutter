require 'swagger_helper'

RSpec.describe 'Exchanges API', type: :request, swagger_doc: 'v1/swagger.yaml' do
  # Endpoint para crear un exchange
  path '/users/{user_id}/exchange' do
    post 'Creates an exchange transaction' do
      tags 'Exchanges'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user_id, in: :path, type: :string, description: 'ID del usuario'
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

  path '/users/{user_id}/exchanges/' do
    get 'Retrieves a specific exchange' do
      tags 'Exchanges'
      produces 'application/json'

      parameter name: :user_id, in: :path, type: :string, description: 'User ID'

      response '200', 'Exchange found' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            exchange_type: { type: :string },
            status: { type: :string }
          },
          required: ['id', 'exchange_type', 'status']

        run_test!
      end

      response '404', 'Exchange not found' do
        schema type: :object,
          properties: {
            error: { type: :string }
          },
          required: ['error']

        run_test!
      end
    end
  end

  path '/users/{user_id}/exchanges/{id}' do
    get 'Lists all exchanges for a user' do
      tags 'Exchanges'
      produces 'application/json'

      parameter name: :user_id, in: :path, type: :string, description: 'User ID'
      parameter name: :id, in: :path, type: :integer, description: 'Exchange ID'

      response '200', 'Exchanges retrieved' do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer },
              exchange_type: { type: :string },
              status: { type: :string }
            },
            required: ['id', 'exchange_type', 'status']
          }

        run_test!
      end
    end
  end
end
