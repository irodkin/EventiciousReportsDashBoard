class CreateTests < ActiveRecord::Migration
  def change
    create_table :tests do |t|
      t.string :title
      t.integer :suiteId	
      t.timestamps null: false
    end
  end
end
