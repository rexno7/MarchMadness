class PoolRefEntry < ActiveRecord::Migration
  def change
    change_table :entries do |t|
      t.references :pool
    end
  end
end
