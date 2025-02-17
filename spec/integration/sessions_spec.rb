require 'swagger_helper'

RSpec.describe 'Sessions API', type: :request, swagger_doc: 'v1/swagger.yaml' do
  path '/login' do
    post 'Create a session' do
      tags 'Sessions'
      consumes 'application/json'
      produces 'application/json'
      
      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string }
        },
        required: ['email', 'password']
      }

      response '200', 'User logged in successfully' do
        schema type: :object,
          properties: {
            first_name: { type: :string },
            last_name: { type: :string },
            email: { type: :string },
            auth_token: {
              type: :object,
              properties: {
                token: { type: :string },
                refresh_token: { type: :string },
                expires_at: { type: :string, format: 'date-time' },
                refresh_token_expires_at: { type: :string, format: 'date-time' }
              }
            }
          },
          required: ['first_name', 'last_name', 'email', 'auth_token']

        let(:credentials) { { email: 'juan@example.com', password: 'Password1!' } }
        before do
          User.create!(
            first_name: "Juan",
            last_name: "Pérez",
            email: "juan@example.com",
            password: "Password1!",
            password_confirmation: "Password1!"
          )
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['auth_token']).to be_present
          expect(data['auth_token']['token']).to be_a(String)
        end
      end

      response '401', 'Invalid credentials' do
        schema type: :object,
          properties: {
            error: { type: :string }
          },
          required: ['error']

        let(:credentials) { { email: 'juan@example.com', password: 'WrongPassword' } }
        run_test!
      end
    end
  end
end
