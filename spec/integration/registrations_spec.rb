require 'swagger_helper'

RSpec.describe 'Registrations API', type: :request, swagger_doc: 'v1/swagger.yaml' do
  path '/signup' do
    post 'Register a new user' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      security []

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              first_name: { type: :string, example: 'John' },
              last_name: { type: :string, example: 'Doe' },
              email: { type: :string, format: :email, example: 'john.doe@example.com' },
              password: { type: :string, example: 'password' },
              password_confirmation: { type: :string, example: 'password' },
              admin: {type: :boolean, example: true}
            },
            required: %w[first_name last_name email password password_confirmation admin]
          }
        },
        required: ['user']
      }

      response '201', 'User created' do
        schema type: :object,
          properties: {
            first_name: { type: :string, example: 'John' },
            last_name: { type: :string, example: 'Doe' },
            email: { type: :string, format: :email, example: 'john.doe@example.com' },
            auth_token: {
              type: :object,
              properties: {
                token: { type: :string, example: 'abcdef123456' },
                refresh_token: { type: :string, example: 'ghijkl789012' },
                expires_at: { type: :string, format: 'date-time', example: '2025-02-18T00:01:42.969Z' },
                refresh_token_expires_at: { type: :string, format: 'date-time', example: '2025-02-25T00:01:42.969Z' }
              },
              required: %w[token refresh_token expires_at refresh_token_expires_at]
            }
          },
          required: %w[first_name last_name email auth_token]

        let(:user) do
          {
            user: {
              first_name: 'John',
              last_name: 'Doe',
              email: 'john.doe@example.com',
              password: 'password',
              password_confirmation: 'password'
            }
          }
        end

        run_test!
      end

      response '422', 'Unprocessable Entity' do
        schema type: :object,
          properties: {
            errors: { type: :array, items: { type: :string } }
          },
          required: ['errors']
        examples 'application/json' => {
          blank: {
            summary: 'Blank fields error',
            value: { errors: ["Email can't be blank"] }
          },
          taken: {
            summary: 'Email already taken error',
            value: { errors: ["Email has already been taken"] }
          }
        }

        let(:user) do
          {
            user: {
              first_name: '',
              last_name: '',
              email: '',
              password: '',
              password_confirmation: ''
            }
          }
        end

        run_test!
      end
    end
  end
end
