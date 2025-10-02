class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :name
      t.integer :game
      t.references :pool

      t.timestamps
    end
  end
end
