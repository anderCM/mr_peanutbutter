require 'rails_helper'

RSpec.describe User, type: :model do
  subject do
    User.new(
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      email: Faker::Internet.email,
      password: "password",
      password_confirmation: "password"
    )
  end

  describe "Validations" do
    it "is valid with all required attributes" do
      expect(subject).to be_valid
    end

    context 'without required attributes' do
      it "first_name" do
        subject.first_name = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:first_name]).to include("can't be blank")
      end

      it "last_name" do
        subject.last_name = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:last_name]).to include("can't be blank")
      end

      it "no es válido sin email" do
        subject.email = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:email]).to include("can't be blank")
      end
    end
  end

  describe "Associations" do
    it { should have_many(:auth_tokens).dependent(:destroy) }
  end
end
