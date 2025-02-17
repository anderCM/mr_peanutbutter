class CreateExchanges < ActiveRecord::Migration[7.2]
  def change
    create_table :exchanges do |t|
      t.references :user, foreign_key: true
      t.string :exchange_type, null: false
      t.decimal :amount_sent, precision: 30, scale: 2, null: false
      t.string :currency_sent, null: false
      t.decimal :amount_received, precision: 30, scale: 2, null: false
      t.string  :currency_received, null: false
      t.decimal :exchange_rate, precision: 30, scale: 2, null: false
      t.string :status, null: false, default: 'pending'
      t.text :comments

      t.timestamps
    end

    add_index :exchanges, :exchange_type
    add_index :exchanges, :status
  end
end
