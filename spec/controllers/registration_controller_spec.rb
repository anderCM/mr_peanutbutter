require 'rails_helper'

RSpec.describe AuthTokenService, type: :service do
  describe "#generate_tokens" do
    context "when given a valid user" do
      let(:user) { create(:user) }
      subject { described_class.new(user) }

      it "creates a new auth token" do
        expect { subject.generate_tokens }.to change { user.auth_tokens.count }.by(1)
      end

      it "returns a valid auth token with required attributes" do
        auth_token = subject.generate_tokens

        expect(auth_token).to be_a(AuthToken)
        expect(auth_token.token).to be_present
        expect(auth_token.refresh_token).to be_present
        expect(auth_token.expires_at).to be > Time.current
        expect(auth_token.refresh_token_expires_at).to be > Time.current
      end
    end

    context "when given an invalid user" do
      subject { described_class.new(nil) }

      it "raises an error indicating the user does not exist" do
        expect { subject.generate_tokens }.to raise_error("User does not exist")
      end
    end
  end
end
