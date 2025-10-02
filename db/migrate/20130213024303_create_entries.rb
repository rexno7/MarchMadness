class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.string :entryname
      t.integer :maxpoints
      t.integer :points
      t.integer :tiebreaker

      t.timestamps
    end
  end
end
