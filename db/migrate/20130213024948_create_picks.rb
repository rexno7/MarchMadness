class CreatePicks < ActiveRecord::Migration
  def change
    create_table :picks do |t|
      t.string :pick
      t.integer :round
      t.integer :game
      t.references :entry
      t.references :pool

      t.timestamps
    end
    add_index :picks, :entry_id
    add_index :picks, :pool_id
  end
end
