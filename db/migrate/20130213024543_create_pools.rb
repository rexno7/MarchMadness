class CreatePools < ActiveRecord::Migration
  def change
    create_table :pools do |t|
      t.string :poolname

      t.timestamps
    end
  end
end
