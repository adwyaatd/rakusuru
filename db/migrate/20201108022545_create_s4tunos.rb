class CreateS4tunos < ActiveRecord::Migration[6.0]
  def change
    create_table :s4tunos do |t|
      t.string :gift_name
      t.integer :donation_amount
      t.integer :ranking

      t.timestamps
    end
  end
end
