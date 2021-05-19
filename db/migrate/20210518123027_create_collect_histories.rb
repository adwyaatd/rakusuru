class CreateCollectHistories < ActiveRecord::Migration[6.1]
  def change
    create_table :collect_histories do |t|
      t.integer :scraping_id
      t.string :search_word
      t.string :domain
      t.integer :existing_shop_count
      t.integer :new_shop_count
      t.integer :updated_shop_count
      t.integer :disable, default: 0

      t.timestamps
    end
  end
end
