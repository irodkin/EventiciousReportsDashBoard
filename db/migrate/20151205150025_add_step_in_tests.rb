class AddStepInTests < ActiveRecord::Migration
  def change
  	add_column :tests, :suite, :string
  	add_column :tests, :steps, :string
  	add_column :tests, :tags, :string
  end
end
