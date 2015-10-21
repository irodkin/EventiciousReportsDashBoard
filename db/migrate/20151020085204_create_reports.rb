class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.datetime :date
      t.string :platform
      t.string :branch
      t.string :suite
      t.string :link
      t.string :device
      t.string :tests
      t.string :server
      t.string :buildurl
      t.string :build
      t.string :job
      t.timestamps null: false
    end
  end
end
