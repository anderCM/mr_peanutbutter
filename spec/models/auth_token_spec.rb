require 'rails_helper'

RSpec.describe AuthToken, type: :model do
  let(:user) { create(:user) }

  subject do
    AuthToken.new(
      token: SecureRandom.hex,
      refresh_token: SecureRandom.hex,
      user: user
    )
  end

  describe "Validations" do
    it "is valid with all required attributes" do
      expect(subject).to be_valid
    end

    it "ensures unique token" do
      subject.save!
      another_auth_token = AuthToken.new(
        token: subject.token,
        refresh_token: SecureRandom.hex,
        user: user
      )
      expect(another_auth_token).not_to be_valid
      expect(another_auth_token.errors[:token]).to include("has already been taken")
    end

    it "ensures unique refresh token" do
      subject.save!
      another_auth_token = AuthToken.new(
        token: SecureRandom.hex,
        refresh_token: subject.refresh_token,
        user: user
      )
      expect(another_auth_token).not_to be_valid
      expect(another_auth_token.errors[:refresh_token]).to include("has already been taken")
    end

    context 'without required attributes' do
        it "invalid without token" do
          subject.token = nil
          expect(subject).not_to be_valid
          expect(subject.errors[:token]).to include("can't be blank")
        end
    
        it "invalid without refresh token" do
          subject.refresh_token = nil
          expect(subject).not_to be_valid
          expect(subject.errors[:refresh_token]).to include("can't be blank")
        end
    end
  end

  describe "Associations" do
    it { should belong_to(:user) }
  end
end
