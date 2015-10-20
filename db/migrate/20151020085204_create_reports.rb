class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.datetime :date
      t.string :platform
      t.string :branch
      t.string :suite
      t.string :link
      t.timestamps null: false
    end
  end
end
