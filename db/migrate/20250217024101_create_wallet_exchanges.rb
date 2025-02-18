class CreateWalletExchanges < ActiveRecord::Migration[7.2]
  def change
    create_table :wallet_exchanges do |t|
      t.references :exchange, foreign_key: true
      t.references :wallet, foreign_key: true
      t.string :operation_type, null: false
      t.decimal :amount, precision: 30, scale: 2, null: false
      t.decimal :previous_balance, precision: 30, scale: 2, null: false
      t.decimal :new_balance, precision: 30, scale: 2, null: false

      t.timestamps
    end

    add_index :wallet_exchanges, [:exchange_id, :wallet_id], unique: true
    add_index :wallet_exchanges, :operation_type
  end
end
