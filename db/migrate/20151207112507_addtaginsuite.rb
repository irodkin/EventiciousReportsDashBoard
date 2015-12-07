class Addtaginsuite < ActiveRecord::Migration
  def change
    add_column :suites, :tag, :string
  end
end
