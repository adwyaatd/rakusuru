class CreateS1Switches < ActiveRecord::Migration[6.0]
  def change
    create_table :s1_switches do |t|
      t.integer :price

      t.timestamps
    end
  end
end
