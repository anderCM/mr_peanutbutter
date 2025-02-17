require 'rails_helper'

RSpec.describe RegistrationsController, type: :controller do
  describe "POST #create" do
    context "with valid parameters" do
      let(:valid_attributes) do
        {
          user: {
            first_name: Faker::Name.first_name,
            last_name: Faker::Name.last_name,
            email: Faker::Internet.unique.email,
            password: "password",
            password_confirmation: "password"
          }
        }
      end

      it "creates a new user and returns a created status" do
        expect {
          post :create, params: valid_attributes
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)

        json = JSON.parse(response.body)
        expect(json).to have_key("first_name")
        expect(json).to have_key("auth_token")
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) do
        {
          user: {
            first_name: "",
            last_name: "",
            email: "",
            password: "",
            password_confirmation: ""
          }
        }
      end

      it "does not create a new user and returns an unprocessable entity status" do
        expect {
          post :create, params: invalid_attributes
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)

        json = JSON.parse(response.body)
        expect(json).to have_key("errors")
      end
    end
  end
end
