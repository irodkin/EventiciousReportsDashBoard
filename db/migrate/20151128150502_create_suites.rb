class CreateSuites < ActiveRecord::Migration
  def change
    create_table :suites do |t|
      t.string :title	
      t.timestamps null: false
    end
  end
end
