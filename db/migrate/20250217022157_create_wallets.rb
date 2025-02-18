class CreateWallets < ActiveRecord::Migration[7.2]
  def change
    create_table :wallets do |t|
      t.references :user, foreign_key: true
      t.string :currency, null: false
      t.decimal :balance, precision: 30, scale: 2, default: 0.0, null: false

      t.timestamps
    end

    add_index :wallets, [:user_id, :currency], unique: true
  end
end
