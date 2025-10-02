class PickUpdate < ActiveRecord::Migration
  def change
    change_table :picks do |t|
      t.remove :pickable_id, :pickable_type
    end
  end
end
