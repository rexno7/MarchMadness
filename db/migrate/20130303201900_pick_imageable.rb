class PickImageable < ActiveRecord::Migration
  def change
    change_table :picks do |t|
      t.remove :entry_id
      t.references :pickable, :polymorphic => true
    end
  end
end
