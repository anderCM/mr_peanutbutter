class CreateAuthTokens < ActiveRecord::Migration[7.2]
  def change
    create_table :auth_tokens do |t|
      t.references :user, foreign_key: true
      t.string :token
      t.string :refresh_token
      t.datetime :expires_at
      t.datetime :refresh_token_expires_at

      t.timestamps
    end

    add_index :auth_tokens, :token, unique: true
    add_index :auth_tokens, :refresh_token, unique: true
  end
end
