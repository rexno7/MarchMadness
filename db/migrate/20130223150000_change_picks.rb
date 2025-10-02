class ChangePicks < ActiveRecord::Migration
  def change
    change_table :picks do |t|
      t.remove :pool_id
      t.references :pickable, :polymorphic => true
    end
  end
end
