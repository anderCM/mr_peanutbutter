require 'swagger_helper'

RSpec.describe 'Wallets API', type: :request, swagger_doc: 'v1/swagger.yaml' do
  path '/users/{user_id}/wallets' do
    get 'Get user wallets' do
      tags 'Wallets'
      produces 'application/json'
      security [ bearer_auth: [] ]
      
      parameter name: :user_id, in: :path, type: :string, description: 'User id'
      response '200', 'Found wallets' do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer },
              currency: { type: :string },
              balance: { type: :number }
            },
            required: ['id', 'currency', 'balance']
          }
        
        run_test!
      end

      response '401', 'Not authorized' do
        schema type: :object,
          properties: {
            error: { type: :string }
          },
          required: ['error']

        run_test!
      end

      response '422', 'Validation error' do
        schema type: :object,
          properties: {
            error: { type: :string }
          },
          required: ['error']

        run_test!
      end
    end
  end
end
